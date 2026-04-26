import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryRewardResolver } from '../../../../model/graphql';
import { createSelectStatement } from '../../sql/reward';
import { type Database } from '../../../../db';

export const reward = (db: Database): QueryRewardResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { id },
    } = gqlarr.getQueryField(info, 'reward')!;

    return createSelectStatement(db, fields, timezone)
      .where('id', '=', id)
      .executeTakeFirst();
  };
};
