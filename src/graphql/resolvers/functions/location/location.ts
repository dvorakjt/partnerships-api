import type { AppContext } from '../../../app-context';
import { sql } from 'kysely';
import { gqlarr, QueryLocationResolver } from '../../../gqlarr';
import { createSelectStatement } from '../../sql/location';
import { type Database } from '../../../../db';

export const location = (db: Database): QueryLocationResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { id },
    } = gqlarr.getQueryField(info, 'location')!;

    const queryBuilder = db.selectFrom('public.active_partner_location');

    return createSelectStatement(queryBuilder, fields, timezone)
      .where(
        'public.active_partner_location.id',
        '=',
        sql<bigint>`CAST(${id} AS BIGINT)`,
      )
      .executeTakeFirst();
  };
};
