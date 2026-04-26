import { db } from '../../../../db';

export function createCountStatement() {
  return db
    .selectFrom('public.active_partner_location')
    .select(({ eb }) => [eb.fn.countAll().as('location_count')]);
}
