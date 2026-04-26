import { QueryCreator } from 'kysely';
import { DB } from '../../../../model/db';

export function createCountStatement(qb: QueryCreator<DB>) {
  return qb
    .selectFrom('public.active_partner_location')
    .select(({ eb }) => [eb.fn.countAll().as('location_count')]);
}
