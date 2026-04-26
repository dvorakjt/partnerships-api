import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryRewardsResolver } from '../../../../model/graphql';
import { clampedOrDefault } from '../../../../util';
import { sql } from 'kysely';
import {
  applyOrderByClause,
  availableRewardTableAlias,
  createFilterExpression,
  createSelectStatement,
} from '../../sql/reward';
import { type Database } from '../../../../db';
import { pgFn } from '../../../../model/db';

export const rewards = (db: Database): QueryRewardsResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { filter, orderBy, take },
    } = gqlarr.getQueryField(info, 'rewards')!;

    const queryBuilder = db.selectFrom(
      pgFn('public.get_available_rewards_in_timezone', [sql.val(timezone)]).as(
        availableRewardTableAlias,
      ),
    );

    return applyOrderByClause(
      createSelectStatement(queryBuilder, fields, timezone).where(eb =>
        createFilterExpression(eb, filter, timezone),
      ),
      orderBy,
    )
      .limit(
        clampedOrDefault(take, {
          min: 0,
          max: 50,
          default: 50,
        }),
      )
      .execute();
  };
};
