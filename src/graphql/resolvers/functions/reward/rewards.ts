import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryRewardsResolver } from '../../../../model/graphql';
import { clampedOrDefault } from '../../../../util';
import {
  applyOrderByClause,
  createFilterExpression,
  createSelectStatement,
} from '../../sql/reward';
import { type Database } from '../../../../db';

export const rewards = (db: Database): QueryRewardsResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { filter, orderBy, take },
    } = gqlarr.getQueryField(info, 'rewards')!;

    return applyOrderByClause(
      createSelectStatement(db, fields, timezone).where(eb =>
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
