import { type Expression, sql } from 'kysely';
import type { BooleanFilter } from '../../../gqlarr';

export function createBooleanFilterExpression(
  lhs: Expression<boolean | null>,
  filter: BooleanFilter,
): Expression<boolean> {
  if (filter._eq) {
    return sql<boolean>`${lhs} = TRUE`;
  }

  if (filter._eq === false) {
    return sql<boolean>`${lhs} = FALSE`;
  }

  if (filter._eq === null) {
    return sql<boolean>`${lhs} IS NULL`;
  }

  // Because of nullability, != TRUE is not the same as = FALSE
  if (filter._neq) {
    return sql<boolean>`${lhs} != TRUE`;
  }

  if (filter._neq === false) {
    return sql<boolean>`${lhs} != FALSE`;
  }

  if (filter._neq === null) {
    return sql<boolean>`${lhs} IS NOT NULL`;
  }

  // Default for when filter is an empty object
  return sql.val(true);
}
