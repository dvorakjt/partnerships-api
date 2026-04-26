import { sql } from 'kysely';
import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryPartnerResolver } from '../../../../model/graphql';
import { createSelectStatement } from '../../sql/partner';
import { type Database } from '../../../../db';

export const partner = (db: Database): QueryPartnerResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { id },
    } = gqlarr.getQueryField(info, 'partner')!;

    const queryBuilder = db.selectFrom('public.active_partner');

    return createSelectStatement(queryBuilder, fields, timezone)
      .where('id', '=', sql<number>`CAST(${id} AS INTEGER)`)
      .executeTakeFirst();
  };
};
