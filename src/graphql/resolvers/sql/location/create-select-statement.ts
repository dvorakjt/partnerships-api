import { SelectQueryBuilder, sql } from 'kysely';
import { jsonBuildObject, jsonObjectFrom } from 'kysely/helpers/postgres';
import { pgFn } from '../../../../db';
import { LocationFields } from '../../../gqlarr';
import { createSelectStatement as createPartnerSelectStatement } from '../partner';
import { DB } from '../../../../db/types';

export function createSelectStatement(
  qb: SelectQueryBuilder<
    DB,
    'public.active_partner_location' | 'public.active_partner',
    any
  >,
  fields: LocationFields,
  timezone: string,
): SelectQueryBuilder<
  DB,
  'public.active_partner_location' | 'public.active_partner',
  any
> {
  return qb.select(eb => {
    return fields.map(field => {
      switch (field.name) {
        case '__typename':
          return eb.val('Location').as(field.alias);
        case 'id':
          return sql<string>`CAST(${eb.ref('public.active_partner_location.id')} AS VARCHAR)`.as(
            field.alias,
          );
        case 'coordinates':
          return jsonBuildObject(
            Object.fromEntries(
              field.fields.map(coordsField => {
                switch (coordsField.name) {
                  case '__typename':
                    return [coordsField.alias, eb.val('Coordinates')];
                  case 'latitude':
                    return [
                      coordsField.alias,
                      pgFn('public.get_latitude', [eb.ref('coordinates')]),
                    ];
                  case 'longitude':
                    return [
                      coordsField.alias,
                      pgFn('public.get_longitude', [eb.ref('coordinates')]),
                    ];
                }
              }),
            ),
          ).as(field.alias);
        case 'distance':
          return pgFn('public.calc_distance_with_units', [
            pgFn('public.make_geographic_point', [
              eb.val(field.arguments.from.longitude),
              eb.val(field.arguments.from.latitude),
            ]),
            eb.ref('coordinates'),
            eb.val(field.arguments.units),
          ]).as(field.alias);
        case 'partner':
          const partnerId = eb.ref('public.active_partner_location.partner_id');
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
