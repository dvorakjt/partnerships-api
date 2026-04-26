import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryPartnerCountResolver } from '../../../../model/graphql';
import {
  createCountStatement,
  createFilterExpression,
} from '../../sql/partner';
import { type Database } from '../../../../db';

export const partnerCount = (
  db: Database,
): QueryPartnerCountResolver<AppContext> => {
  return async (_parent, _args, { timezone }, info) => {
    const {
      arguments: { filter },
    } = gqlarr.getQueryField(info, 'partnerCount')!;

    const { partner_count } = await createCountStatement(db)
      .where(eb => createFilterExpression(eb, filter, timezone))
      .executeTakeFirstOrThrow();

    return BigInt(partner_count);
  };
};
