import { QueryCreator, sql } from 'kysely';
import { DB, pgFn } from '../../../../model/db';

export function createCountStatement(qb: QueryCreator<DB>, timezone: string) {
  return qb
    .selectFrom(
      pgFn('public.get_available_rewards_in_timezone', [sql.val(timezone)]).as(
        'available_reward',
      ),
    )
    .select(eb => [eb.fn.countAll().as('reward_count')]);
}
