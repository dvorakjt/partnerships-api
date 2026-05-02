import { SelectQueryBuilder } from 'kysely';
import { DB } from '../../../../db/types';

export function createCountStatement(
  qb: SelectQueryBuilder<DB, 'public.active_partner', any>,
) {
  return qb.select(({ eb }) => [eb.fn.countAll().as('partner_count')]);
}
