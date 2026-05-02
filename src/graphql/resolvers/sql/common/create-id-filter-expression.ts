import { type Expression, sql } from 'kysely';
import type { IDFilter } from '../../../gqlarr';

function createIdFilterExpression(
  lhs: Expression<String>,
  filter: IDFilter,
): Expression<boolean>;
function createIdFilterExpression<T>(
  lhs: Expression<T>,
  filter: IDFilter,
  cast: (value: string) => Expression<T>,
): Expression<boolean>;
function createIdFilterExpression(
  lhs: Expression<any>,
  filter: IDFilter,
  cast?: (value: string) => Expression<any>,
): Expression<boolean> {
  /*
    Explicitly check for undefined and null to enable comparison with explictly 
    set falsy values like 0 and ''
  */
  if (filter._eq !== undefined && filter._eq !== null) {
    return sql<boolean>`${lhs} = ${cast ? cast(filter._eq) : filter._eq}`;
  }

  if (filter._eq === null) {
    return sql<boolean>`${lhs} IS NULL`;
  }

  if (filter._neq !== undefined && filter._neq !== null) {
    return sql<boolean>`${lhs} != ${cast ? cast(filter._neq) : filter._neq}`;
  }

  if (filter._neq === null) {
    return sql<boolean>`${lhs} IS NOT NULL`;
  }

  if (filter._gt !== undefined && filter._gt !== null) {
    return sql<boolean>`${lhs} > ${cast ? cast(filter._gt) : filter._gt}`;
  }

  if (filter._gte !== undefined && filter._gte !== null) {
    return sql<boolean>`${lhs} >= ${cast ? cast(filter._gte) : filter._gte}`;
  }

  if (filter._lt !== undefined && filter._lt !== null) {
    return sql<boolean>`${lhs} < ${cast ? cast(filter._lt) : filter._lt}`;
  }

  if (filter._lte !== undefined && filter._lte !== null) {
    return sql<boolean>`${lhs} <= ${cast ? cast(filter._lte) : filter._lte}`;
  }

  // Default for when filter is an empty object
  return sql.val(true);
}

export { createIdFilterExpression };
