import { gqlarr, type QueryLanguagesResolver } from '../../../gqlarr';
import { createSelectStatement } from '../../sql/language';
import type { AppContext } from '../../../app-context';
import type { Database } from '../../../../db';

export const languages = (db: Database): QueryLanguagesResolver<AppContext> => {
  return async (_parent, _args, _context, info) => {
    const { fields } = gqlarr.getQueryField(info, 'languages')!;
    const queryBuilder = db.selectFrom('public.language');
    return createSelectStatement(queryBuilder, fields).execute();
  };
};
