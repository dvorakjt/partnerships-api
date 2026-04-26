import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryRewardCountResolver } from '../../../../model/graphql';
import {
  availableRewardTableAlias,
  createCountStatement,
  createFilterExpression,
} from '../../sql/reward';
import { type Database } from '../../../../db';
import { sql } from 'kysely';
import { pgFn } from '../../../../model/db';

export const rewardCount = (
  db: Database,
): QueryRewardCountResolver<AppContext> => {
  return async (_parent, _args, { timezone }, info) => {
    const rewardCountField = gqlarr.getQueryField(info, 'rewardCount')!;

    const queryBuilder = db.selectFrom(
      pgFn('public.get_available_rewards_in_timezone', [sql.val(timezone)]).as(
        availableRewardTableAlias,
      ),
    );

    const { reward_count } = await createCountStatement(queryBuilder)
      .where(eb =>
        createFilterExpression(eb, rewardCountField.arguments.filter, timezone),
      )
      .executeTakeFirstOrThrow();

    return BigInt(reward_count);
  };
};
