import { gqlarr, QueryCategoriesResolver } from '../../../gqlarr';
import type { AppContext } from '../../../app-context';
import type { Database } from '../../../../db';

export const categories = (
  db: Database,
): QueryCategoriesResolver<AppContext> => {
  return async (_parent, _args, _context, info) => {
    const {
      arguments: { languageTag },
    } = gqlarr.getQueryField(info, 'categories')!;

    const result = await db
      .selectFrom('public.category')
      .innerJoin(
        'public.category_translation',
        'public.category.id',
        'public.category_translation.category_id',
      )
      .select('category_name')
      .where('language_tag', '=', languageTag)
      .execute();

    return result.map(row => row.category_name);
  };
};
