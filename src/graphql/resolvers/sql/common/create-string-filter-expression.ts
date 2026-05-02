import { type Expression, sql } from 'kysely';
import type { StringFilter } from '../../../gqlarr';

export function createStringFilterExpression(
  lhs: Expression<string | null>,
  filter: StringFilter,
): Expression<boolean> {
  if (typeof filter._eq?._value === 'string') {
    let rhs: string | Expression<string> = filter._eq._value;

    if (filter._eq._ignoreCase) {
      lhs = sql<string>`UPPER(${lhs})`;
      rhs = sql<string>`UPPER(${rhs})`;
    }

    return sql<boolean>`${lhs} = ${rhs}`;
  }

  if (filter._eq === null || (filter._eq && filter._eq._value === null)) {
    return sql<boolean>`${lhs} IS NULL`;
  }

  if (typeof filter._neq?._value === 'string') {
    let rhs: string | Expression<string> = filter._neq._value;

    if (filter._neq._ignoreCase) {
      lhs = sql<string>`UPPER(${lhs})`;
      rhs = sql<string>`UPPER(${rhs})`;
    }

    return sql<boolean>`${lhs} != ${rhs}`;
  }

  if (filter._neq === null || (filter._neq && filter._neq._value === null)) {
    return sql<boolean>`${lhs} IS NOT NULL`;
  }

  if (typeof filter._gt === 'string') {
    return sql<boolean>`${lhs} > ${filter._gt}`;
  }

  if (typeof filter._gte === 'string') {
    return sql<boolean>`${lhs} >= ${filter._gte}`;
  }

  if (typeof filter._lt === 'string') {
    return sql<boolean>`${lhs} < ${filter._lt}`;
  }

  if (typeof filter._lte === 'string') {
    return sql<boolean>`${lhs} <= ${filter._lte}`;
  }

  if (typeof filter._like?._value === 'string') {
    if (filter._like._ignoreCase) {
      return sql<boolean>`${lhs} ILIKE ${filter._like._value}`;
    }

    return sql<boolean>`${lhs} LIKE ${filter._like._value}`;
  }

  // Default for when filter is an empty object
  return sql.val(true);
}
