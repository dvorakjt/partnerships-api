import { ExpressionWrapper, SelectQueryBuilder, sql } from 'kysely';
import { jsonArrayFrom, jsonObjectFrom } from 'kysely/helpers/postgres';
import { pgFn } from '../../../../db';
import { PartnerFields } from '../../../gqlarr';
import {
  applyOrderByClause as applyLocationsOrderByClause,
  createCountStatement as createLocationCountStatement,
  createFilterExpression as createLocationsFilterExpression,
  createSelectStatement as createLocationsSelectStatement,
} from '../location';
import {
  availableRewardTableAlias,
  applyOrderByClause as applyRewardsOrderByClause,
  DBWithAvailableRewardTable,
  createCountStatement as createRewardCountStatement,
  createFilterExpression as createRewardsFilterExpression,
  createSelectStatement as createRewardsSelectStatement,
} from '../reward';
import { clampedOrDefault } from '../../../../util';
import { DB } from '../../../../db/types';

export function createSelectStatement(
  qb: SelectQueryBuilder<DB, 'public.active_partner', any>,
  fields: PartnerFields,
  timezone: string,
): SelectQueryBuilder<DB, 'public.active_partner', any> {
  return qb.select(eb => {
    const partnerId = eb.ref('public.active_partner.id');

    return fields.map(field => {
      switch (field.name) {
        case '__typename':
          return eb.val('Partner').as(field.alias);
        case 'id':
          return sql<string>`CAST(${eb.ref('public.active_partner.id')} AS VARCHAR)`.as(
            field.alias,
          );
        case 'locations':
          return createLocationsSelectStatementWithFilterOrderAndLimit(
            eb.selectFrom('public.active_partner_location'),
            partnerId,
            field,
            timezone,
          );
        case 'locationCount':
          return createLocationCountStatementWithFilter(
            eb.selectFrom('public.active_partner_location'),
            partnerId,
            field,
            timezone,
          );
        case 'rewards':
          return createRewardsSelectStatementWithFilterOrderAndLimit(
            eb.selectFrom(
              pgFn('public.get_available_rewards_in_timezone', [
                eb.val(timezone),
              ]).as(availableRewardTableAlias),
            ),
            partnerId,
            field,
            timezone,
          );
        case 'rewardCount':
          return createRewardCountStatementWithFilter(
            eb.selectFrom(
              pgFn('public.get_available_rewards_in_timezone', [
                eb.val(timezone),
              ]).as(availableRewardTableAlias),
            ),
            partnerId,
            field,
            timezone,
          );
        case 'translatedDetails':
          return createTranslatedDetailsExpression(
            eb.selectFrom('public.partner_details_translation'),
            partnerId,
            field,
          );
      }
    });
  });
}

function createLocationsSelectStatementWithFilterOrderAndLimit(
  qb: SelectQueryBuilder<
    DB,
    'public.active_partner_location' | 'public.active_partner',
    any
  >,
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'locations' }>,
  timezone: string,
) {
  return jsonArrayFrom(
    applyLocationsOrderByClause(
      createLocationsSelectStatement(qb, field.fields, timezone).where(eb =>
        eb.and([
          eb('partner_id', '=', partnerId),
          createLocationsFilterExpression(eb, field.arguments.filter, timezone),
        ]),
      ),
      field.arguments.orderBy,
    ).limit(
      clampedOrDefault(field.arguments.take, {
        min: 0,
        max: 50,
        default: 50,
      }),
    ),
  ).as(field.alias);
}

function createLocationCountStatementWithFilter(
  qb: SelectQueryBuilder<DB, 'public.active_partner_location', any>,
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'locationCount' }>,
  timezone: string,
) {
  return createLocationCountStatement(qb)
    .where(eb =>
      eb.and([
        eb('partner_id', '=', partnerId),
        createLocationsFilterExpression(eb, field.arguments.filter, timezone),
      ]),
    )
    .as(field.alias);
}

function createRewardsSelectStatementWithFilterOrderAndLimit(
  qb: SelectQueryBuilder<DBWithAvailableRewardTable, 'available_reward', any>,
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'rewards' }>,
  timezone: string,
) {
  return jsonArrayFrom(
    applyRewardsOrderByClause(
      createRewardsSelectStatement(qb, field.fields, timezone).where(eb =>
        eb.and([
          eb('partner_id', '=', partnerId),
          createRewardsFilterExpression(eb, field.arguments.filter, timezone),
        ]),
      ),
      field.arguments.orderBy,
    ).limit(
      clampedOrDefault(field.arguments.take, {
        min: 0,
        max: 50,
        default: 50,
      }),
    ),
  ).as(field.alias);
}

function createRewardCountStatementWithFilter(
  qb: SelectQueryBuilder<DBWithAvailableRewardTable, 'available_reward', any>,
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'rewardCount' }>,
  timezone: string,
) {
  return createRewardCountStatement(qb)
    .where(eb =>
      eb.and([
        eb('partner_id', '=', partnerId),
        createRewardsFilterExpression(eb, field.arguments.filter, timezone),
      ]),
    )
    .as(field.alias);
}

function createTranslatedDetailsExpression(
  qb: SelectQueryBuilder<DB, 'public.partner_details_translation', any>,
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'translatedDetails' }>,
) {
  const { languageTag } = field.arguments;

  return jsonObjectFrom(
    qb
      .select(eb => {
        return field.fields.map(field => {
          switch (field.name) {
            case '__typename':
              return eb.val('PartnerDetails').as(field.alias);
            case 'name':
              return eb.ref('name').as(field.alias);
            case 'description':
              return eb.ref('description').as(field.alias);
            case 'motivation':
              return eb.ref('motivation').as(field.alias);
            case 'logoUrl':
              return eb.ref('logo_url').as(field.alias);
            case 'webAddressUrl':
              return eb.ref('web_address_url').as(field.alias);
            case 'webAddressText':
              return eb.ref('web_address_text').as(field.alias);
          }
        });
      })
      .where(eb =>
        eb.and([
          eb('public.partner_details_translation.partner_id', '=', partnerId),
          eb(
            'public.partner_details_translation.language_tag',
            '=',
            languageTag,
          ),
        ]),
      ),
  ).as(field.alias);
}
