import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryRewardResolver } from '../../../../model/graphql';
import {
  availableRewardTableAlias,
  createSelectStatement,
} from '../../sql/reward';
import { type Database } from '../../../../db';
import { sql } from 'kysely';
import { pgFn } from '../../../../model/db';

export const reward = (db: Database): QueryRewardResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { id },
    } = gqlarr.getQueryField(info, 'reward')!;

    const queryBuilder = db.selectFrom(
      pgFn('public.get_available_rewards_in_timezone', [sql.val(timezone)]).as(
        availableRewardTableAlias,
      ),
    );

    return createSelectStatement(queryBuilder, fields, timezone)
      .where('id', '=', id)
      .executeTakeFirst();
  };
};
