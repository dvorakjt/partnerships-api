import { sql } from 'kysely';
import { gqlarr, type QueryPartnerResolver } from '../../../gqlarr';
import { createSelectStatement } from '../../sql/partner';
import type { AppContext } from '../../../app-context';
import type { Database } from '../../../../db';

export const partner = (db: Database): QueryPartnerResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { id },
    } = gqlarr.getQueryField(info, 'partner')!;

    const queryBuilder = db.selectFrom('public.active_partner');

    return createSelectStatement(queryBuilder, fields, timezone)
      .where(
        'public.active_partner.id',
        '=',
        sql<number>`CAST(${id} AS INTEGER)`,
      )
      .executeTakeFirst();
  };
};
