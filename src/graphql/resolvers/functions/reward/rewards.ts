import { gqlarr, type QueryRewardsResolver } from '../../../gqlarr';
import { clampedOrDefault } from '../../../../util';
import { sql } from 'kysely';
import {
  applyOrderByClause,
  availableRewardTableAlias,
  createFilterExpression,
  createSelectStatement,
} from '../../sql/reward';
import { pgFn, type Database } from '../../../../db';
import type { AppContext } from '../../../app-context';

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
