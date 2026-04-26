import {
  ExpressionBuilder,
  ExpressionWrapper,
  SelectQueryBuilder,
  sql,
} from 'kysely';
import {
  jsonArrayFrom,
  jsonBuildObject,
  jsonObjectFrom,
} from 'kysely/helpers/postgres';
import { db, pgFn } from '../../../../db';
import { PartnerFields } from '../../../../model/graphql';
import {
  applyOrderByClause as applyLocationsOrderByClause,
  createCountStatement as createLocationCountStatement,
  createFilterExpression as createLocationsFilterExpression,
  createSelectStatement as createLocationsSelectStatement,
} from '../location';
import {
  applyOrderByClause as applyRewardsOrderByClause,
  createCountStatement as createRewardCountStatement,
  createFilterExpression as createRewardsFilterExpression,
  createSelectStatement as createRewardsSelectStatement,
} from '../reward';
import { clampedOrDefault } from '../../../../util';
import { DB } from '../../../../model/db';

export function createSelectStatement(
  fields: PartnerFields,
  timezone: string,
): SelectQueryBuilder<DB, 'public.active_partner', any> {
  return db.selectFrom('public.active_partner').select(eb => {
    const partnerId = eb.ref('public.active_partner.id');

    return fields.map(field => {
      switch (field.name) {
        case '__typename':
          return eb.val('Partner').as(field.alias);
        case 'id':
          return sql<string>`CAST(${eb.ref('id')} AS VARCHAR)`.as(field.alias);
        case 'locations':
          return createLocationsSelectStatementWithFilterOrderAndLimit(
            partnerId,
            field,
            timezone,
          );
        case 'locationCount':
          return createLocationCountStatementWithFilter(
            partnerId,
            field,
            timezone,
          );
        case 'rewards':
          return createRewardsSelectStatementWithFilterOrderAndLimit(
            partnerId,
            field,
            timezone,
          );
        case 'rewardCount':
          return createRewardCountStatementWithFilter(
            partnerId,
            field,
            timezone,
          );
        case 'translatedDetails':
          return createTranslatedDetailsExpression(partnerId, field);
      }
    });
  });
}

function createLocationsSelectStatementWithFilterOrderAndLimit(
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'locations' }>,
  timezone: string,
) {
  return jsonArrayFrom(
    applyLocationsOrderByClause(
      createLocationsSelectStatement(field.fields, timezone).where(eb =>
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
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'locationCount' }>,
  timezone: string,
) {
  return createLocationCountStatement()
    .where(eb =>
      eb.and([
        eb('partner_id', '=', partnerId),
        createLocationsFilterExpression(eb, field.arguments.filter, timezone),
      ]),
    )
    .as(field.alias);
}

function createRewardsSelectStatementWithFilterOrderAndLimit(
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'rewards' }>,
  timezone: string,
) {
  return jsonArrayFrom(
    applyRewardsOrderByClause(
      createRewardsSelectStatement(field.fields, timezone).where(eb =>
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
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'rewardCount' }>,
  timezone: string,
) {
  return createRewardCountStatement(timezone)
    .where(eb =>
      eb.and([
        eb('partner_id', '=', partnerId),
        createRewardsFilterExpression(eb, field.arguments.filter, timezone),
      ]),
    )
    .as(field.alias);
}

function createTranslatedDetailsExpression(
  partnerId: ExpressionWrapper<DB, 'public.active_partner', number>,
  field: Extract<PartnerFields[number], { name: 'translatedDetails' }>,
) {
  const { languageTag } = field.arguments;

  return jsonObjectFrom(
    db
      .selectFrom('public.partner_details_translation')
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
