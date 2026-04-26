import { SelectQueryBuilder } from 'kysely';
import { DB } from '../../../../model/db';

export function createCountStatement(
  qb: SelectQueryBuilder<DB, 'public.active_partner_location', any>,
) {
  return qb.select(({ eb }) => [eb.fn.countAll().as('location_count')]);
}
