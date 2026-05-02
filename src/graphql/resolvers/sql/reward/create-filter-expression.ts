import { Expression, ExpressionBuilder, sql, SqlBool } from 'kysely';
import { pgFn } from '../../../../db';
import { DB } from '../../../../db/types';
import {
  RedemptionForumArrayFilter,
  RewardDetailsFilter,
  RewardFilter,
  VoucherOwnership,
  VoucherOwnershipFilter,
} from '../../../gqlarr';
import { createBooleanFilterExpression } from '../common/create-boolean-filter-expression';
import {
  createDateTimeFilterExpression,
  createIdFilterExpression,
  createStringArrayFilterExpression,
  createStringFilterExpression,
} from '../common';
import { createFilterExpression as createPartnerFilterExpression } from '../partner';
import type { DBWithAvailableRewardTable } from './create-select-statement';

export function createFilterExpression(
  eb: ExpressionBuilder<DBWithAvailableRewardTable, 'available_reward'>,
  filter: RewardFilter | undefined,
  timezone: string,
): Expression<SqlBool> {
  if (filter?._and) {
    const conditions = filter._and.map(f =>
      createFilterExpression(eb, f, timezone),
    );
    return conditions.length ? eb.and(conditions) : eb.val(true);
  }

  if (filter?._or) {
    const conditions = filter._or.map(f =>
      createFilterExpression(eb, f, timezone),
    );
    return conditions.length ? eb.or(conditions) : eb.val(true);
  }

  if (filter?._not) {
    return eb.not(createFilterExpression(eb, filter._not, timezone));
  }

  if (filter?.id) {
    return createIdFilterExpression(eb.ref('available_reward.id'), filter.id);
  }

  if (filter?.redemptionForums) {
    return createRedemptionForumsFilterExpression(eb, filter.redemptionForums);
  }

  if (filter?.voucherOwnership) {
    return createVoucherOwnershipFilterExpression(eb, filter.voucherOwnership);
  }

  if (filter?.earliestFutureExpiryDate) {
    return createDateTimeFilterExpression(
      pgFn('public.calc_earliest_future_expiration_date', [
        eb.ref('available_reward.id'),
        eb.val(timezone),
      ]),
      filter.earliestFutureExpiryDate,
    );
  }

  if (filter?.hasUsageOrQuantityLimit) {
    return createBooleanFilterExpression(
      pgFn('public.has_usage_or_quantity_limit', [
        eb.ref('available_reward.id'),
      ]),
      filter.hasUsageOrQuantityLimit,
    );
  }

  if (filter?.translatedDetails) {
    return eb.exists(
      eb
        .selectFrom('public.reward_details_translation')
        .select('public.reward_details_translation.reward_id')
        .where(eb =>
          eb.and([
            eb('reward_id', '=', eb.ref('available_reward.id')),
            eb('language_tag', '=', filter.translatedDetails!._languageTag),
            createTranslatedDetailsFilterExpression(
              eb,
              filter.translatedDetails!._filter,
              filter.translatedDetails!._languageTag,
            ),
          ]),
        ),
    );
  }

  if (filter?.partner) {
    const partnerId = eb.ref('available_reward.partner_id');

    return eb.exists(
      eb
        .selectFrom('public.active_partner')
        .select('public.active_partner.id')
        .where(eb =>
          eb.and([
            eb('public.active_partner.id', '=', partnerId),
            createPartnerFilterExpression(eb, filter!.partner, timezone),
          ]),
        ),
    );
  }

  // Catch-all
  return eb.val(true);
}

function createRedemptionForumsFilterExpression(
  eb: ExpressionBuilder<DBWithAvailableRewardTable, 'available_reward'>,
  filter: RedemptionForumArrayFilter,
) {
  if (filter._eq) {
    return sql<boolean>`array_sort(${eb.ref('redemption_forums')}) = array_sort(${eb.val(filter._eq)})::redemption_forum[]`;
  }

  if (filter._eq === null) {
    return eb('redemption_forums', 'is', null);
  }

  if (filter._neq) {
    return sql<boolean>`array_sort(${eb.ref('redemption_forums')}) != array_sort(${eb.val(filter._neq)})::redemption_forum[]`;
  }

  if (filter._neq === null) {
    return eb('redemption_forums', 'is not', null);
  }

  if (filter._containsEl) {
    return sql<boolean>`${eb.val(filter._containsEl)} = ANY(${eb.ref('redemption_forums')})`;
  }

  if (filter._containsArr) {
    return sql<boolean>`${eb.ref('redemption_forums')} @> ${eb.val(filter._containsArr)}`;
  }

  if (filter._containedBy) {
    return sql<boolean>`${eb.ref('redemption_forums')} <@ ${eb.val(filter._containedBy)}`;
  }

  if (filter._overlaps) {
    return sql<boolean>`${eb.ref('redemption_forums')} && ${eb.val(filter._overlaps)}`;
  }

  // Catch-all for when filter is an empty object
  return eb.val(true);
}

function createVoucherOwnershipFilterExpression(
  eb: ExpressionBuilder<DBWithAvailableRewardTable, 'available_reward'>,
  filter: VoucherOwnershipFilter,
) {
  if (filter._eq) {
    return eb(
      eb
        .case()
        .when('voucher_type', '=', 'MULTIPLE_USE')
        .then(VoucherOwnership.SHARED)
        .else(VoucherOwnership.INDIVIDUAL)
        .end(),
      '=',
      filter._eq,
    );
  }

  if (filter._eq === null) {
    return eb('voucher_type', 'is', null);
  }

  if (filter._neq) {
    return eb(
      eb
        .case()
        .when('voucher_type', '!=', 'MULTIPLE_USE')
        .then(VoucherOwnership.SHARED)
        .else(VoucherOwnership.INDIVIDUAL)
        .end(),
      '=',
      filter._neq,
    );
  }

  if (filter._neq === null) {
    return eb('voucher_type', 'is not', null);
  }

  return eb.val(true);
}

function createTranslatedDetailsFilterExpression(
  eb: ExpressionBuilder<DB, 'public.reward_details_translation'>,
  filter: RewardDetailsFilter,
  languageTag: string,
): Expression<SqlBool> {
  if (filter._and) {
    const conditions = filter._and.map(f => {
      return createTranslatedDetailsFilterExpression(eb, f, languageTag);
    });

    return conditions.length ? eb.and(conditions) : eb.val(true);
  }

  if (filter._or) {
    const conditions = filter._or.map(f => {
      return createTranslatedDetailsFilterExpression(eb, f, languageTag);
    });

    return conditions.length ? eb.or(conditions) : eb.val(true);
  }

  if (filter._not) {
    return eb.not(
      createTranslatedDetailsFilterExpression(eb, filter._not, languageTag),
    );
  }

  if (filter.categories) {
    return createStringArrayFilterExpression(
      pgFn('public.get_translated_reward_categories', [
        eb.ref('reward_id'),
        eb.val(languageTag),
      ]),
      filter.categories,
    );
  }

  if (filter.shortDescription) {
    return createStringFilterExpression(
      eb.ref('short_description'),
      filter.shortDescription,
    );
  }

  if (filter.longDescription) {
    return createStringFilterExpression(
      eb.ref('long_description'),
      filter.longDescription,
    );
  }

  // Catch-all for when filter is an empty object
  return eb.val(true);
}
