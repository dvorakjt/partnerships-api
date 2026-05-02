import { type Expression, sql } from 'kysely';
import type { DateTimeFilter } from '../../../gqlarr';

export function createDateTimeFilterExpression(
  lhs: Expression<Date | null>,
  filter: DateTimeFilter,
): Expression<boolean> {
  if (filter._eq) {
    return sql<boolean>`${lhs} = ${filter._eq}`;
  }

  if (filter._eq === null) {
    return sql<boolean>`${lhs} IS NULL`;
  }

  if (filter._neq) {
    return sql<boolean>`${lhs} != ${filter._neq}`;
  }

  if (filter._neq === null) {
    return sql<boolean>`${lhs} IS NOT NULL`;
  }

  if (filter._gt) {
    return sql<boolean>`${lhs} > ${filter._gt}`;
  }

  if (filter._gte) {
    return sql<boolean>`${lhs} >= ${filter._gte}`;
  }

  if (filter._lt) {
    return sql<boolean>`${lhs} < ${filter._lt}`;
  }

  if (filter._lte) {
    return sql<boolean>`${lhs} <= ${filter._lte}`;
  }

  // Default for when filter is an empty object
  return sql.val(true);
}
