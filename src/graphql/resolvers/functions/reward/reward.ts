import { gqlarr, type QueryRewardResolver } from '../../../gqlarr';
import {
  availableRewardTableAlias,
  createSelectStatement,
} from '../../sql/reward';
import { pgFn, type Database } from '../../../../db';
import { sql } from 'kysely';
import type { AppContext } from '../../../app-context';

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
      .where('available_reward.id', '=', id)
      .executeTakeFirst();
  };
};
