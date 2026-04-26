import { db } from '../../../../db';

export function createCountStatement() {
  return db
    .selectFrom('public.active_partner')
    .select(({ eb }) => [eb.fn.countAll().as('partner_count')]);
}
