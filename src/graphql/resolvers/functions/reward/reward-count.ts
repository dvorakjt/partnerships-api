import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryRewardCountResolver } from '../../../../model/graphql';
import { createCountStatement, createFilterExpression } from '../../sql/reward';
import { type Database } from '../../../../db';

export const rewardCount = (
  db: Database,
): QueryRewardCountResolver<AppContext> => {
  return async (_parent, _args, { timezone }, info) => {
    const rewardCountField = gqlarr.getQueryField(info, 'rewardCount')!;

    const { reward_count } = await createCountStatement(db, timezone)
      .where(eb =>
        createFilterExpression(eb, rewardCountField.arguments.filter, timezone),
      )
      .executeTakeFirstOrThrow();

    return BigInt(reward_count);
  };
};
