import { gqlarr, QueryLocationsResolver } from '../../../../model/graphql';
import { clampedOrDefault } from '../../../../util';
import { AppContext } from '../../../../model/graphql';
import {
  applyOrderByClause,
  createFilterExpression,
  createSelectStatement,
} from '../../sql/location';
import { type Database } from '../../../../db';

export const locations = (db: Database): QueryLocationsResolver<AppContext> => {
  return (_parent, _args, { timezone }, info) => {
    const {
      fields,
      arguments: { filter, orderBy, take },
    } = gqlarr.getQueryField(info, 'locations')!;

    const queryBuilder = db.selectFrom('public.active_partner_location');

    return applyOrderByClause(
      createSelectStatement(queryBuilder, fields, timezone).where(eb =>
        createFilterExpression(eb, filter, timezone),
      ),
      orderBy,
    )
      .limit(
        clampedOrDefault(take, {
          min: 0,
          max: 50,
          default: 50,
        }),
      )
      .execute();
  };
};
