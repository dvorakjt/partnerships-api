import { SelectQueryBuilder } from 'kysely';
import { DBWithAvailableRewardTable } from './create-select-statement';

export function createCountStatement(
  qb: SelectQueryBuilder<DBWithAvailableRewardTable, 'available_reward', any>,
) {
  return qb.select(eb => [eb.fn.countAll().as('reward_count')]);
}
