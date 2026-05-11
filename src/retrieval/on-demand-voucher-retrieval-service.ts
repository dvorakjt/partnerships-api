import type {
  DeployRetrieverResult,
  RetrieverPayload,
  RetrieverSecretValues,
} from './types';

export interface OnDemandVoucherRetrievalService {
  deployRetriever(
    rewardId: string,
    retrieverCode: string,
    secrets?: RetrieverSecretValues,
  ): Promise<DeployRetrieverResult>;
  invokeRetriever(rewardId: string): Promise<RetrieverPayload>;
}
