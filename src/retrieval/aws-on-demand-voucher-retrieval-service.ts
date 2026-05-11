import {
  CreateFunctionCommand,
  GetFunctionCommand,
  InvokeCommand,
  LambdaClient,
  ResourceNotFoundException,
  Runtime,
  TagResourceCommand,
  UpdateFunctionCodeCommand,
  UpdateFunctionConfigurationCommand,
} from '@aws-sdk/client-lambda';
import {
  CreateSecretCommand,
  ResourceExistsException,
  SecretsManagerClient,
  UpdateSecretCommand,
} from '@aws-sdk/client-secrets-manager';
import { IAMClient, PutRolePolicyCommand } from '@aws-sdk/client-iam';
import JSZip from 'jszip';
import type { OnDemandVoucherRetrievalService } from './on-demand-voucher-retrieval-service';
import {
  retrieverPayloadSchema,
  type DeployRetrieverResult,
  type RetrieverPayload,
  type RetrieverSecretValues,
} from './types';
// Refinements:
// TSDoc comments on config value properties
// what config options are actually needed? how will this authenticate to aws? (role?)
// Remember, ts will need to be compiled to js before deployment

export interface AwsOnDemandVoucherRetrievalServiceConfig {
  region: string;
  lambdaExecutionRoleArn: string;
  invokerRoleArn: string;
  lambdaRuntime?: Extract<Runtime, `nodejs${string}`>;
  handler?: string;
  timeoutSeconds?: number;
  memorySizeMb?: number;
  secretsExtensionLayerArn?: string;
}

interface AwsDeployedSecretDescriptor {
  name: string;
  arn: string;
}

type ParsedRetrieverPayload = ReturnType<typeof retrieverPayloadSchema.parse>;
type ParsedLocalizedRetrieverText = NonNullable<
  ParsedRetrieverPayload['voucherDetails'][number]['localized']
>[number];

export class AwsOnDemandVoucherRetrievalService implements OnDemandVoucherRetrievalService {
  private static readonly LAMBDA_TAG_SET = {
    app: 'partnerships-api',
  } as const;

  // AWS Lambda function names must be <= 64 characters. This prefix is 22
  // characters long, so appending a canonical UUID (36 chars) yields 58.
  private static readonly LAMBDA_NAME_PREFIX = 'on-demand-voucher_rid-';

  // AWS Secrets Manager secret names can be up to 512 characters. This
  // prefix is 22 characters long, so appending a canonical UUID (36 chars)
  // yields 58.
  private static readonly SECRET_NAME_PREFIX = 'od-voucher-secret_rid-';

  // AWS IAM inline policy names can be up to 128 characters. This prefix is 25
  // characters long, so appending a canonical UUID (36 chars) yields 61.
  private static readonly INVOKE_POLICY_NAME_PREFIX =
    'on-demand-voucher-invoke-';

  // AWS IAM inline policy names can be up to 128 characters. This prefix is 32
  // characters long, so appending a canonical UUID (36 chars) yields 68.
  private static readonly SECRET_ACCESS_POLICY_NAME_PREFIX =
    'on-demand-voucher-secret-access-';

  private readonly lambdaClient: LambdaClient;
  private readonly secretsManagerClient: SecretsManagerClient;
  private readonly iamClient: IAMClient;
  private readonly lambdaExecutionRoleArn: string;
  private readonly invokerRoleArn: string;
  private readonly lambdaRuntime: Extract<Runtime, `nodejs${string}`>;
  private readonly handler: string;
  private readonly timeoutSeconds: number;
  private readonly memorySizeMb: number;
  private readonly secretsExtensionLayerArn: string | undefined;

  constructor(config: AwsOnDemandVoucherRetrievalServiceConfig) {
    this.lambdaClient = new LambdaClient({ region: config.region });
    this.secretsManagerClient = new SecretsManagerClient({
      region: config.region,
    });
    this.iamClient = new IAMClient({ region: config.region });
    this.lambdaExecutionRoleArn = config.lambdaExecutionRoleArn;
    this.invokerRoleArn = config.invokerRoleArn;
    this.lambdaRuntime = config.lambdaRuntime ?? Runtime.nodejs24x;
    this.handler = config.handler ?? 'index.handler';
    this.timeoutSeconds = config.timeoutSeconds ?? 30;
    this.memorySizeMb = config.memorySizeMb ?? 256;
    this.secretsExtensionLayerArn = config.secretsExtensionLayerArn;
  }

  async deployRetriever(
    rewardId: string,
    retrieverCode: string,
    secrets?: RetrieverSecretValues,
  ): Promise<DeployRetrieverResult> {
    this.assertCanonicalUuid(rewardId);

    const functionName = this.createLambdaName(rewardId);
    const zippedCode = await this.zipCode(retrieverCode);
    const deployedSecret = await this.upsertSecrets(rewardId, secrets ?? {});

    const functionEnvironment = {
      Variables: {
        ...(deployedSecret ?
          {
            RETRIEVER_SECRET_ID: deployedSecret.name,
          }
        : {}),
      },
    };

    let functionArn: string | undefined;
    let functionExists = false;

    try {
      const existingFunction = await this.lambdaClient.send(
        new GetFunctionCommand({
          FunctionName: functionName,
        }),
      );

      functionArn = existingFunction.Configuration?.FunctionArn;
      functionExists = true;
    } catch (error) {
      if (!(error instanceof ResourceNotFoundException)) {
        throw error;
      }
    }

    if (functionExists) {
      await this.lambdaClient.send(
        new UpdateFunctionCodeCommand({
          FunctionName: functionName,
          ZipFile: zippedCode,
        }),
      );

      await this.lambdaClient.send(
        new UpdateFunctionConfigurationCommand({
          FunctionName: functionName,
          Role: this.lambdaExecutionRoleArn,
          Handler: this.handler,
          Runtime: this.lambdaRuntime,
          Timeout: this.timeoutSeconds,
          MemorySize: this.memorySizeMb,
          Environment: functionEnvironment,
          Layers:
            this.secretsExtensionLayerArn ?
              [this.secretsExtensionLayerArn]
            : undefined,
        }),
      );
    } else {
      const createdFunction = await this.lambdaClient.send(
        new CreateFunctionCommand({
          FunctionName: functionName,
          Role: this.lambdaExecutionRoleArn,
          Handler: this.handler,
          Runtime: this.lambdaRuntime,
          Timeout: this.timeoutSeconds,
          MemorySize: this.memorySizeMb,
          Code: {
            ZipFile: zippedCode,
          },
          Environment: functionEnvironment,
          Layers:
            this.secretsExtensionLayerArn ?
              [this.secretsExtensionLayerArn]
            : undefined,
          Publish: false,
        }),
      );

      functionArn = createdFunction.FunctionArn;
    }

    if (!functionArn) {
      throw new Error(
        `AWS Lambda did not return a function ARN for reward \"${rewardId}\".`,
      );
    }

    await this.lambdaClient.send(
      new TagResourceCommand({
        Resource: functionArn,
        Tags: AwsOnDemandVoucherRetrievalService.LAMBDA_TAG_SET,
      }),
    );

    await this.grantLambdaSecretAccess(
      rewardId,
      this.lambdaExecutionRoleArn,
      deployedSecret?.arn,
    );

    await this.grantInvokeAccess(this.invokerRoleArn, functionArn, rewardId);

    return {
      rewardId,
      retrieverName: functionName,
      deployedSecrets: deployedSecret ? [{ name: deployedSecret.name }] : [],
    };
  }

  async invokeRetriever(rewardId: string): Promise<RetrieverPayload> {
    this.assertCanonicalUuid(rewardId);

    const functionName = this.createLambdaName(rewardId);
    const invokeResult = await this.lambdaClient.send(
      new InvokeCommand({
        FunctionName: functionName,
        InvocationType: 'RequestResponse',
        Payload: new TextEncoder().encode('{}'),
      }),
    );

    const payloadText = this.decodePayload(invokeResult.Payload);

    if (invokeResult.FunctionError) {
      throw new Error(
        payloadText ||
          `Retriever invocation failed for reward \"${rewardId}\".`,
      );
    }

    if (!payloadText) {
      throw new Error(
        `Retriever invocation returned an empty payload for reward \"${rewardId}\".`,
      );
    }

    return retrieverPayloadSchema.parse(JSON.parse(payloadText));
  }

  private createLambdaName(rewardId: string) {
    return `${AwsOnDemandVoucherRetrievalService.LAMBDA_NAME_PREFIX}${rewardId}`;
  }

  private createSecretName(rewardId: string) {
    return `${AwsOnDemandVoucherRetrievalService.SECRET_NAME_PREFIX}${rewardId}`;
  }

  private createInlinePolicyName(prefix: string, rewardId: string) {
    return `${prefix}${rewardId}`;
  }

  private async zipCode(code: string) {
    const zip = new JSZip();

    // Add the code string as a file inside the zip
    zip.file('index.js', code);

    // Generate the zip as a Uint8Array
    const zipBuffer = await zip.generateAsync({
      type: 'uint8array',
      compression: 'DEFLATE',
      compressionOptions: { level: 6 },
    });

    return zipBuffer;
  }

  private async upsertSecrets(
    rewardId: string,
    secrets: RetrieverSecretValues,
  ): Promise<AwsDeployedSecretDescriptor | undefined> {
    if (Object.keys(secrets).length === 0) {
      return undefined;
    }

    const secretName = this.createSecretName(rewardId);
    const secretString = JSON.stringify(secrets);

    try {
      const createdSecret = await this.secretsManagerClient.send(
        new CreateSecretCommand({
          Name: secretName,
          SecretString: secretString,
        }),
      );

      return {
        name: secretName,
        arn: createdSecret.ARN ?? secretName,
      };
    } catch (error) {
      if (!(error instanceof ResourceExistsException)) {
        throw error;
      }
    }

    const updatedSecret = await this.secretsManagerClient.send(
      new UpdateSecretCommand({
        SecretId: secretName,
        SecretString: secretString,
      }),
    );

    return {
      name: secretName,
      arn: updatedSecret.ARN ?? secretName,
    };
  }

  private async grantLambdaSecretAccess(
    rewardId: string,
    lambdaRoleArn: string,
    secretArn?: string,
  ) {
    if (!secretArn) {
      return;
    }

    await this.iamClient.send(
      new PutRolePolicyCommand({
        RoleName: this.roleNameFromArn(lambdaRoleArn),
        PolicyName: this.createInlinePolicyName(
          AwsOnDemandVoucherRetrievalService.SECRET_ACCESS_POLICY_NAME_PREFIX,
          rewardId,
        ),
        PolicyDocument: JSON.stringify({
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Action: ['secretsmanager:GetSecretValue'],
              Resource: secretArn,
            },
          ],
        }),
      }),
    );
  }

  private async grantInvokeAccess(
    invokerRoleArn: string,
    functionArn: string,
    rewardId: string,
  ) {
    await this.iamClient.send(
      new PutRolePolicyCommand({
        RoleName: this.roleNameFromArn(invokerRoleArn),
        PolicyName: this.createInlinePolicyName(
          AwsOnDemandVoucherRetrievalService.INVOKE_POLICY_NAME_PREFIX,
          rewardId,
        ),
        PolicyDocument: JSON.stringify({
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Action: ['lambda:InvokeFunction'],
              Resource: functionArn,
            },
          ],
        }),
      }),
    );
  }

  private decodePayload(payload?: Uint8Array) {
    if (!payload || payload.length === 0) {
      return '';
    }

    return new TextDecoder().decode(payload);
  }

  private roleNameFromArn(roleArn: string) {
    const roleName = roleArn.split('/').at(-1);

    if (!roleName) {
      throw new Error(`Unable to determine role name from ARN \"${roleArn}\".`);
    }

    return roleName;
  }

  private assertCanonicalUuid(rewardId: string) {
    const canonicalUuidPattern =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!canonicalUuidPattern.test(rewardId)) {
      throw new Error(
        `Expected rewardId to be a canonical UUID, received \"${rewardId}\".`,
      );
    }
  }
}
