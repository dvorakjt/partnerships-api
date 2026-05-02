import { gqlarr, type QueryPartnerCountResolver } from '../../../gqlarr';
import {
  createCountStatement,
  createFilterExpression,
} from '../../sql/partner';
import type { AppContext } from '../../../app-context';
import type { Database } from '../../../../db';

export const partnerCount = (
  db: Database,
): QueryPartnerCountResolver<AppContext> => {
  return async (_parent, _args, { timezone }, info) => {
    const {
      arguments: { filter },
    } = gqlarr.getQueryField(info, 'partnerCount')!;

    const queryBuilder = db.selectFrom('public.active_partner');

    const { partner_count } = await createCountStatement(queryBuilder)
      .where(eb => createFilterExpression(eb, filter, timezone))
      .executeTakeFirstOrThrow();

    return BigInt(partner_count);
  };
};
