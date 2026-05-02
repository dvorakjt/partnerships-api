import { gqlarr, type QueryPartnersResolver } from '../../../gqlarr';
import { clampedOrDefault } from '../../../../util';
import {
  applyOrderByClause,
  createFilterExpression,
  createSelectStatement,
} from '../../sql/partner';
import type { AppContext } from '../../../app-context';
import type { Database } from '../../../../db';

export const partners = (db: Database): QueryPartnersResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { filter, orderBy, take },
    } = gqlarr.getQueryField(info, 'partners')!;

    const queryBuilder = db.selectFrom('public.active_partner');

    return applyOrderByClause(
      createSelectStatement(queryBuilder, fields, timezone).where(eb =>
        createFilterExpression(eb, filter, timezone),
      ),
      orderBy,
    )
      .limit(clampedOrDefault(take, { min: 0, max: 50, default: 50 }))
      .execute();
  };
};
