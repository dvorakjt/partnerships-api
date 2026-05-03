import { z } from 'zod';

// Refinements: define types for methods called internally, zod schemas only for
// stuff coming back from AWS -- these should be defined in the aws impl file

export const rewardIdSchema = z.string().uuid();

export const redemptionMethodSchema = z.enum([
  'CODE',
  'QR_CODE',
  'LINK',
  'MANUAL',
]);

const baseVoucherDetailsSchema = z.object({
  redemptionMethod: redemptionMethodSchema,
  instructions: z.string().min(1),
});

export const codeVoucherDetailsSchema = baseVoucherDetailsSchema.extend({
  redemptionMethod: z.literal('CODE'),
  redemptionCode: z.string().min(1),
});

export const qrCodeVoucherDetailsSchema = baseVoucherDetailsSchema.extend({
  redemptionMethod: z.literal('QR_CODE'),
  redemptionQRCode: z.string().min(1),
});

export const linkVoucherDetailsSchema = baseVoucherDetailsSchema.extend({
  redemptionMethod: z.literal('LINK'),
  redemptionLinkUrl: z.string().url(),
  redemptionLinkText: z.string().min(1).nullable().optional(),
});

export const manualVoucherDetailsSchema = baseVoucherDetailsSchema.extend({
  redemptionMethod: z.literal('MANUAL'),
});

export const voucherDetailsSchema = z.discriminatedUnion('redemptionMethod', [
  codeVoucherDetailsSchema,
  qrCodeVoucherDetailsSchema,
  linkVoucherDetailsSchema,
  manualVoucherDetailsSchema,
]);

export const translatedVoucherDetailsSchema = z.object({
  languageTag: z.string().min(1),
  voucherDetails: z.array(voucherDetailsSchema),
});

export const retrieverPayloadSchema = z.object({
  expirationDate: z.string().datetime().nullable().optional(),
  translatedDetails: z.array(translatedVoucherDetailsSchema).min(1),
});

export const retrieverSecretValuesSchema = z.record(
  z.string().min(1),
  z.string(),
);

export const deployedRetrieverSecretSchema = z.object({
  name: z.string().min(1),
});

export const retrieverRuntimeContextSchema = z.object({
  secrets: retrieverSecretValuesSchema.default({}),
});

export interface DeployRetrieverInput {
  rewardId: string;
  zipBytes: Uint8Array;
  secrets?: RetrieverSecretValues;
}

export interface InvokeRetrieverInput {
  rewardId: string;
}

export interface DeployedRetrieverSecret {
  name: string;
}

export interface DeployRetrieverResult {
  rewardId: string;
  retrieverName: string;
  deployedSecrets: DeployedRetrieverSecret[];
}

export type RedemptionMethod = z.infer<typeof redemptionMethodSchema>;
export type VoucherDetails = z.infer<typeof voucherDetailsSchema>;
export type TranslatedVoucherDetails = z.infer<
  typeof translatedVoucherDetailsSchema
>;
export type RetrieverPayload = z.infer<typeof retrieverPayloadSchema>;
export type RetrieverSecretValues = z.infer<typeof retrieverSecretValuesSchema>;
export type RetrieverRuntimeContext = z.infer<
  typeof retrieverRuntimeContextSchema
>;

export type OnDemandVoucherRetriever = (
  context: RetrieverRuntimeContext,
) => Promise<RetrieverPayload> | RetrieverPayload;
