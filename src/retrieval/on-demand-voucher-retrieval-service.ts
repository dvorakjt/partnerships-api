import type {
  DeployRetrieverInput,
  DeployRetrieverResult,
  InvokeRetrieverInput,
  RetrieverPayload,
} from './types';

export interface OnDemandVoucherRetrievalService {
  deployRetriever(input: DeployRetrieverInput): Promise<DeployRetrieverResult>;
  invokeRetriever(input: InvokeRetrieverInput): Promise<RetrieverPayload>;
}
