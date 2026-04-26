import { gqlarr, type AppContext } from '../../../../model/graphql';
import type { QueryLanguagesResolver } from '../../../../model/graphql';
import { createSelectStatement } from '../../sql/language';
import { type Database } from '../../../../db';

export const languages = (db: Database): QueryLanguagesResolver<AppContext> => {
  return async (_parent, _args, _context, info) => {
    const { fields } = gqlarr.getQueryField(info, 'languages')!;
    const queryBuilder = db.selectFrom('public.language');
    return createSelectStatement(queryBuilder, fields).execute();
  };
};
