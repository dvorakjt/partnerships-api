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
import type { OnDemandVoucherRetrievalService } from './on-demand-voucher-retrieval-service';
import {
  retrieverPayloadSchema,
  type DeployRetrieverInput,
  type DeployRetrieverResult,
  type InvokeRetrieverInput,
  type RetrieverPayload,
  type RetrieverSecretValues,
} from './types';

// Refinements:
// Verify length limits for various names
// TSDoc comments on config value properties
// Private methods go after public ones
// just validate reward id once at top level

const lambdaTagSet = {
  app: 'partnerships-api',
} as const;

const canonicalUuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

// AWS Lambda function names must be <= 64 characters. This prefix is 22
// characters long, so appending a canonical UUID (36 chars) yields 58.
const lambdaNamePrefix = 'on-demand-voucher_rid-';

// AWS Secrets Manager secret names can be up to 512 characters. This
// prefix is 22 characters long, so appending a canonical UUID (36 chars)
// yields 58.
const secretNamePrefix = 'od-voucher-secret_rid-';

// AWS IAM inline policy names can be up to 128 characters. This prefix is 25
// characters long, so appending a canonical UUID (36 chars) yields 61.
const invokePolicyNamePrefix = 'on-demand-voucher-invoke-';

// AWS IAM inline policy names can be up to 128 characters. This prefix is 32
// characters long, so appending a canonical UUID (36 chars) yields 68.
const secretAccessPolicyNamePrefix = 'on-demand-voucher-secret-access-';

export interface AwsOnDemandVoucherRetrievalServiceConfig {
  region: string;
  lambdaExecutionRoleArn: string;
  invokerRoleArn: string;
  lambdaRuntime?: 'nodejs20.x' | 'nodejs22.x';
  handler?: string;
  timeoutSeconds?: number;
  memorySizeMb?: number;
  secretsExtensionLayerArn?: string;
}

interface AwsDeployedSecretDescriptor {
  name: string;
  arn: string;
}

export class AwsOnDemandVoucherRetrievalService implements OnDemandVoucherRetrievalService {
  private readonly lambdaClient: LambdaClient;
  private readonly secretsManagerClient: SecretsManagerClient;
  private readonly iamClient: IAMClient;

  constructor(
    private readonly config: AwsOnDemandVoucherRetrievalServiceConfig,
  ) {
    this.lambdaClient = new LambdaClient({ region: config.region });
    this.secretsManagerClient = new SecretsManagerClient({
      region: config.region,
    });
    this.iamClient = new IAMClient({ region: config.region });
  }

  createLambdaName(rewardId: string) {
    this.assertCanonicalUuid(rewardId);

    return `${lambdaNamePrefix}${rewardId}`;
  }

  private createSecretName(rewardId: string) {
    this.assertCanonicalUuid(rewardId);

    return `${secretNamePrefix}${rewardId}`;
  }

  private getLambdaRuntime() {
    return this.config.lambdaRuntime === 'nodejs20.x' ?
        Runtime.nodejs20x
      : Runtime.nodejs22x;
  }

  private getLambdaExecutionRoleArn() {
    return this.readRequiredConfigValue(
      this.config.lambdaExecutionRoleArn,
      'lambdaExecutionRoleArn',
    );
  }

  private getInvokerRoleArn() {
    return this.readRequiredConfigValue(
      this.config.invokerRoleArn,
      'invokerRoleArn',
    );
  }

  private getHandler() {
    return this.config.handler ?? 'index.handler';
  }

  private getTimeoutSeconds() {
    return this.config.timeoutSeconds ?? 30;
  }

  private getMemorySizeMb() {
    return this.config.memorySizeMb ?? 256;
  }

  private createInlinePolicyName(prefix: string, rewardId: string) {
    return `${prefix}${rewardId}`;
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
          secretAccessPolicyNamePrefix,
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
          invokePolicyNamePrefix,
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

  async deployRetriever(
    input: DeployRetrieverInput,
  ): Promise<DeployRetrieverResult> {
    const lambdaExecutionRoleArn = this.getLambdaExecutionRoleArn();
    const invokerRoleArn = this.getInvokerRoleArn();
    const handler = this.getHandler();
    const timeoutSeconds = this.getTimeoutSeconds();
    const memorySizeMb = this.getMemorySizeMb();
    const functionName = this.createLambdaName(input.rewardId);
    const deployedSecret = await this.upsertSecrets(
      input.rewardId,
      input.secrets ?? {},
    );
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
          ZipFile: input.zipBytes,
        }),
      );

      await this.lambdaClient.send(
        new UpdateFunctionConfigurationCommand({
          FunctionName: functionName,
          Role: lambdaExecutionRoleArn,
          Handler: handler,
          Runtime: this.getLambdaRuntime(),
          Timeout: timeoutSeconds,
          MemorySize: memorySizeMb,
          Environment: functionEnvironment,
          Layers:
            this.config.secretsExtensionLayerArn ?
              [this.config.secretsExtensionLayerArn]
            : undefined,
        }),
      );
    } else {
      const createdFunction = await this.lambdaClient.send(
        new CreateFunctionCommand({
          FunctionName: functionName,
          Role: lambdaExecutionRoleArn,
          Handler: handler,
          Runtime: this.getLambdaRuntime(),
          Timeout: timeoutSeconds,
          MemorySize: memorySizeMb,
          Code: {
            ZipFile: input.zipBytes,
          },
          Environment: functionEnvironment,
          Layers:
            this.config.secretsExtensionLayerArn ?
              [this.config.secretsExtensionLayerArn]
            : undefined,
          Publish: false,
        }),
      );

      functionArn = createdFunction.FunctionArn;
    }

    if (!functionArn) {
      throw new Error(
        `AWS Lambda did not return a function ARN for reward \"${input.rewardId}\".`,
      );
    }

    await this.lambdaClient.send(
      new TagResourceCommand({
        Resource: functionArn,
        Tags: lambdaTagSet,
      }),
    );

    await this.grantLambdaSecretAccess(
      input.rewardId,
      lambdaExecutionRoleArn,
      deployedSecret?.arn,
    );
    await this.grantInvokeAccess(invokerRoleArn, functionArn, input.rewardId);

    return {
      rewardId: input.rewardId,
      retrieverName: functionName,
      deployedSecrets: deployedSecret ? [{ name: deployedSecret.name }] : [],
    };
  }

  async invokeRetriever(
    input: InvokeRetrieverInput,
  ): Promise<RetrieverPayload> {
    const functionName = this.createLambdaName(input.rewardId);
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
          `Retriever invocation failed for reward \"${input.rewardId}\".`,
      );
    }

    if (!payloadText) {
      throw new Error(
        `Retriever invocation returned an empty payload for reward \"${input.rewardId}\".`,
      );
    }

    return retrieverPayloadSchema.parse(JSON.parse(payloadText));
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

  private readRequiredConfigValue(value: string | undefined, name: string) {
    if (!value) {
      throw new Error(
        `Missing required AWS retrieval config value \"${name}\".`,
      );
    }

    return value;
  }

  private assertCanonicalUuid(rewardId: string) {
    if (!canonicalUuidPattern.test(rewardId)) {
      throw new Error(
        `Expected rewardId to be a canonical UUID, received \"${rewardId}\".`,
      );
    }
  }
}
