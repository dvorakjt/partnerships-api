import { gqlarr, QueryLocationCountResolver } from '../../../gqlarr';
import {
  createCountStatement,
  createFilterExpression,
} from '../../sql/location';
import type { AppContext } from '../../../app-context';
import type { Database } from '../../../../db';

export const locationCount = (
  db: Database,
): QueryLocationCountResolver<AppContext> => {
  return async (_parent, _args, { timezone }, info) => {
    const {
      arguments: { filter },
    } = gqlarr.getQueryField(info, 'locationCount')!;

    const queryBuilder = db.selectFrom('public.active_partner_location');

    const query = createCountStatement(queryBuilder).where(eb =>
      createFilterExpression(eb, filter, timezone),
    );

    const result = await query.executeTakeFirstOrThrow();
    return BigInt(result.location_count);
  };
};
