import { z } from 'zod';

// Fix the shapes of these things
export const redemptionMethodSchema = z.enum(['CODE', 'QR_CODE', 'LINK']);

export const localizedLinkUrlSchema = z.object({
  languageTag: z.string().min(1),
  redemptionLinkUrl: z.string().url(),
});

const baseRetrieverVoucherDetailSchema = z.object({
  redemptionMethod: redemptionMethodSchema,
  localized: z.array(localizedLinkUrlSchema).min(1).optional(),
});

export const codeRetrieverVoucherDetailSchema =
  baseRetrieverVoucherDetailSchema.extend({
    redemptionMethod: z.literal('CODE'),
    redemptionCode: z.string().min(1),
    localized: z.undefined().optional(),
  });

export const qrCodeRetrieverVoucherDetailSchema =
  baseRetrieverVoucherDetailSchema.extend({
    redemptionMethod: z.literal('QR_CODE'),
    redemptionQRCode: z.string().min(1),
    localized: z.undefined().optional(),
  });

export const linkRetrieverVoucherDetailSchema =
  baseRetrieverVoucherDetailSchema.extend({
    redemptionMethod: z.literal('LINK'),
    redemptionLinkUrl: z.string().url(),
  });

export const retrieverVoucherDetailSchema = z.discriminatedUnion(
  'redemptionMethod',
  [
    codeRetrieverVoucherDetailSchema,
    qrCodeRetrieverVoucherDetailSchema,
    linkRetrieverVoucherDetailSchema,
  ],
);

export const retrieverPayloadSchema = z.object({
  voucherDetails: z.array(retrieverVoucherDetailSchema).min(1),
});

export const retrieverSecretValuesSchema = z.record(
  z.string().min(1),
  z.string(),
);

export const retrieverRuntimeContextSchema = z.object({
  secrets: retrieverSecretValuesSchema.default({}),
});

export type RedemptionMethod = z.infer<typeof redemptionMethodSchema>;

export type LocalizedRetrieverText = z.infer<typeof localizedLinkUrlSchema>;

export type CodeRetrieverVoucherDetail = z.infer<
  typeof codeRetrieverVoucherDetailSchema
>;

export type QRCodeRetrieverVoucherDetail = z.infer<
  typeof qrCodeRetrieverVoucherDetailSchema
>;

export type LinkRetrieverVoucherDetail = z.infer<
  typeof linkRetrieverVoucherDetailSchema
>;

export type RetrieverVoucherDetail = z.infer<
  typeof retrieverVoucherDetailSchema
>;

export type RetrieverPayload = z.infer<typeof retrieverPayloadSchema>;
export type RetrieverSecretValues = z.infer<typeof retrieverSecretValuesSchema>;
export type RetrieverRuntimeContext = z.infer<
  typeof retrieverRuntimeContextSchema
>;

export interface DeployedRetrieverSecret {
  name: string;
}

// Does this even need to exist? Could maybe just be Promise<void>
export interface DeployRetrieverResult {
  rewardId: string;
  retrieverName: string;
  deployedSecrets: DeployedRetrieverSecret[];
}

export type OnDemandVoucherRetriever = (
  context: RetrieverRuntimeContext,
) => Promise<RetrieverPayload> | RetrieverPayload;
