import { SelectQueryBuilder, sql } from 'kysely';
import { pgFn } from '../../../../db';
import { DB } from '../../../../db/types';
import { LocationOrderByCriteria, SortOrder } from '../../../gqlarr';
import { applyOrderByClause as applyPartnerOrderByClause } from '../partner';

export function applyOrderByClause(
  qb: SelectQueryBuilder<
    DB,
    'public.active_partner_location' | 'public.active_partner',
    any
  >,
  orderByClauses: LocationOrderByCriteria[] = [],
) {
  return orderByClauses.reduce((builder, clause) => {
    if (clause.id) {
      return builder.orderBy(
        eb =>
          sql`${eb.ref('public.active_partner_location.id')}
            ${sql.raw(clause.id?._order === SortOrder.ASC ? 'asc' : 'desc')} 
            ${sql.raw(clause.id?._nullsLast ? 'NULLS LAST' : 'NULLS FIRST')}`,
      );
    }
    if (clause.distance) {
      return builder.orderBy(
        eb =>
          sql`${eb.ref('public.active_partner_location.coordinates')} <-> ${pgFn(
            'public.make_geographic_point',
            [
              eb.val(clause.distance!._from.longitude),
              eb.val(clause.distance!._from.latitude),
            ],
          )} 
          ${sql.raw(clause.distance!._sortOptions._order === SortOrder.ASC ? 'asc' : 'desc')}
          ${sql.raw(clause.distance!._sortOptions._nullsLast ? 'NULLS LAST' : 'NULLS FIRST')}`,
      );
    }
    if (clause.partner) {
      return applyPartnerOrderByClause(
        builder.innerJoin(
          'public.active_partner',
          'public.active_partner_location.partner_id',
          'public.active_partner.id',
        ),
        [clause.partner],
      );
    }
    return builder;
  }, qb);
}
