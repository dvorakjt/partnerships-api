import {
  retrieverRuntimeContextSchema,
  type OnDemandVoucherRetriever,
  type RetrieverRuntimeContext,
} from './types';

const defaultExtensionPort = '2773';
const secretValueRecordSchema = retrieverRuntimeContextSchema.shape.secrets;

const readRequiredEnvironmentVariable = (name: string) => {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing required environment variable \"${name}\".`);
  }

  return value;
};

export const fetchRetrieverSecrets =
  async (): Promise<RetrieverRuntimeContext> => {
    const secretId = process.env.RETRIEVER_SECRET_ID;

    if (!secretId) {
      return { secrets: {} };
    }

    const sessionToken = readRequiredEnvironmentVariable('AWS_SESSION_TOKEN');
    const extensionPort =
      process.env.PARAMETERS_SECRETS_EXTENSION_HTTP_PORT ||
      defaultExtensionPort;
    const secretUrl = new URL(
      `/secretsmanager/get?secretId=${encodeURIComponent(secretId)}`,
      `http://localhost:${extensionPort}`,
    );

    const response = await fetch(secretUrl, {
      headers: {
        'X-Aws-Parameters-Secrets-Token': sessionToken,
      },
    });

    if (!response.ok) {
      throw new Error(
        `Failed to load retriever secrets: ${response.status} ${response.statusText}`,
      );
    }

    const payload = (await response.json()) as {
      SecretString?: string;
    };

    if (!payload.SecretString) {
      return { secrets: {} };
    }

    const parsedSecrets = JSON.parse(payload.SecretString) as unknown;

    return {
      secrets: secretValueRecordSchema.parse(parsedSecrets),
    };
  };

export const createAwsOnDemandVoucherRetrieverHandler = (
  retriever: OnDemandVoucherRetriever,
) => {
  return async (_event?: unknown, _context?: unknown) => {
    const runtimeContext = await fetchRetrieverSecrets();
    return retriever(runtimeContext);
  };
};
