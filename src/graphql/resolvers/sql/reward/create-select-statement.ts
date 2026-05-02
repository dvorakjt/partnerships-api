import { SelectQueryBuilder } from 'kysely';
import { jsonObjectFrom } from 'kysely/helpers/postgres';
import { pgFn } from '../../../../db';
import { DB } from '../../../../db/types';
import { RewardFields, VoucherOwnership } from '../../../gqlarr';
import { ExpressionBuilder } from 'kysely';
import { createSelectStatement as createPartnerSelectStatement } from '../partner';

export const availableRewardTableAlias = 'available_reward';

export type DBWithAvailableRewardTable = DB & {
  [availableRewardTableAlias]: DB['public.reward'];
};

export function createSelectStatement(
  qb: SelectQueryBuilder<DBWithAvailableRewardTable, 'available_reward', any>,
  fields: RewardFields,
  timezone: string,
): SelectQueryBuilder<DBWithAvailableRewardTable, 'available_reward', any> {
  return qb.select(eb => {
    return fields.map(field => {
      switch (field.name) {
        case '__typename':
          return eb.val('Reward').as(field.alias);
        case 'id':
          return eb.ref('available_reward.id').as(field.alias);
        case 'redemptionForums':
          return pgFn('pg_catalog.array_sort', [
            eb.ref('redemption_forums'),
          ]).as(field.alias);
        case 'voucherOwnership':
          return createVoucherOwnershipExpression(eb, field);
        case 'hasUsageOrQuantityLimit':
          return pgFn('public.has_usage_or_quantity_limit', [
            eb.ref('available_reward.id'),
          ]).as(field.alias);
        case 'earliestFutureExpiryDate':
          return pgFn('public.calc_earliest_future_expiration_date', [
            eb.ref('available_reward.id'),
            eb.val(timezone),
          ]).as(field.alias);
        case 'translatedDetails':
          return createTranslatedDetailsExpression(
            eb.selectFrom('public.reward_details_translation'),
            field,
          );
        case 'partner':
          const partnerId = eb.ref('available_reward.partner_id');
          return jsonObjectFrom(
            createPartnerSelectStatement(
              eb.selectFrom('public.active_partner'),
              field.fields,
              timezone,
            ).where('public.active_partner.id', '=', partnerId),
          ).as(field.alias);
      }
    });
  });
}

function createVoucherOwnershipExpression(
  eb: ExpressionBuilder<DBWithAvailableRewardTable, 'available_reward'>,
  field: Extract<RewardFields[number], { name: 'voucherOwnership' }>,
) {
  return eb
    .case()
    .when('voucher_type', '=', 'MULTIPLE_USE')
    .then(VoucherOwnership.SHARED)
    .else(VoucherOwnership.INDIVIDUAL)
    .end()
    .as(field.alias);
}

function createTranslatedDetailsExpression(
  qb: SelectQueryBuilder<
    DBWithAvailableRewardTable,
    'public.reward_details_translation' | 'available_reward',
    any
  >,
  field: Extract<RewardFields[number], { name: 'translatedDetails' }>,
) {
  const { languageTag } = field.arguments;

  return jsonObjectFrom(
    qb
      .select(eb => {
        return field.fields.map(field => {
          switch (field.name) {
            case '__typename':
              return eb.val('RewardDetails').as(field.alias);
            case 'categories':
              return pgFn('public.get_translated_reward_categories', [
                eb.ref('available_reward.id'),
                eb.val(languageTag),
              ]).as(field.alias);
            case 'shortDescription':
              return eb
                .ref('public.reward_details_translation.short_description')
                .as(field.alias);
            case 'longDescription':
              return eb
                .ref('public.reward_details_translation.long_description')
                .as(field.alias);
          }
        });
      })
      .where(eb =>
        eb.and([
          eb(
            'public.reward_details_translation.reward_id',
            '=',
            eb.ref('available_reward.id'),
          ),
          eb(
            'public.reward_details_translation.language_tag',
            '=',
            languageTag,
          ),
        ]),
      ),
  ).as(field.alias);
}
