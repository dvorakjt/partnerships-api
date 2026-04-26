import { ExpressionBuilder, Expression, SqlBool, sql } from 'kysely';
import { pgFn } from '../../../../db';
import { DB } from '../../../../model/db';
import { DistanceFilter, LocationFilter } from '../../../../model/graphql';
import { createIdFilterExpression } from '../common';
import { createFilterExpression as createPartnerFilterExpression } from '../partner';

export function createFilterExpression(
  eb: ExpressionBuilder<DB, 'public.active_partner_location'>,
  filter: LocationFilter | undefined,
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
    return createIdFilterExpression(
      eb.ref('id'),
      filter.id,
      id => sql<bigint>`CAST(${id} AS BIGINT)`,
    );
  }

  if (filter?.distance) {
    return createDistanceFilterExpression(eb, filter.distance);
  }

  if (filter?.partner) {
    const partnerId = eb.ref('public.active_partner_location.partner_id');

    return eb.exists(
      eb
        .selectFrom('public.active_partner')
        .select('id')
        .where(eb =>
          eb.and([
            eb('public.active_partner.id', '=', partnerId),
            createPartnerFilterExpression(eb, filter!.partner, timezone),
          ]),
        ),
    );
  }

  // Default for when filter is an empty object
  return eb.val(true);
}

function createDistanceFilterExpression(
  eb: ExpressionBuilder<DB, 'public.active_partner_location'>,
  filter: DistanceFilter,
) {
  return pgFn('public.st_dwithin', [
    eb.ref('coordinates'),
    pgFn('public.make_geographic_point', [
      eb.val(filter._within._from.longitude),
      eb.val(filter._within._from.latitude),
    ]),
    pgFn('public.convert_distance', [
      eb.val(filter._within._radius),
      eb.val(filter._within._units),
      eb.val('METERS' as const),
    ]),
    eb.val(true),
  ]);
}
