import type { AppContext } from '../../../../model/graphql';
import { gqlarr, QueryLocationCountResolver } from '../../../../model/graphql';
import {
  createCountStatement,
  createFilterExpression,
} from '../../sql/location';
import { type Database } from '../../../../db';

export const locationCount = (
  db: Database,
): QueryLocationCountResolver<AppContext> => {
  return async (_parent, _args, { timezone }, info) => {
    const {
      arguments: { filter },
    } = gqlarr.getQueryField(info, 'locationCount')!;

    const query = createCountStatement(db).where(eb =>
      createFilterExpression(eb, filter, timezone),
    );

    const result = await query.executeTakeFirstOrThrow();
    return BigInt(result.location_count);
  };
};
