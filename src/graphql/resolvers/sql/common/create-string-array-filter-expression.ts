import { type Expression, sql } from 'kysely';
import type { StringArrayFilter } from '../../../gqlarr';
import { pgFn } from '../../../../db';

export function createStringArrayFilterExpression(
  lhs: Expression<string[] | null>,
  filter: StringArrayFilter,
): Expression<boolean> {
  if (filter._eq) {
    let rhs: Expression<string[] | null> = sql.val(filter._eq._value);

    if (filter._eq._ignoreCase) {
      lhs = pgFn('public.to_uppercase_array', [lhs]);
      rhs = pgFn('public.to_uppercase_array', [rhs]);
    }

    return sql<boolean>`array_sort(${lhs}) = array_sort(${rhs})`;
  }

  if (filter._eq === null) {
    return sql<boolean>`${lhs} IS NULL`;
  }

  if (filter._neq) {
    let rhs: Expression<string[] | null> = sql.val(filter._neq._value);

    if (filter._neq._ignoreCase) {
      lhs = pgFn('public.to_uppercase_array', [lhs]);
      rhs = pgFn('public.to_uppercase_array', [rhs]);
    }

    return sql<boolean>`array_sort(${lhs}) != array_sort(${rhs})`;
  }

  if (filter._neq === null) {
    return sql<boolean>`${lhs} IS NOT NULL`;
  }

  if (filter._containsEl) {
    let rhs: Expression<string | null> = sql.val(filter._containsEl._value);

    if (filter._containsEl._ignoreCase) {
      lhs = pgFn('public.to_uppercase_array', [lhs]);
      rhs = sql`UPPER(${rhs})`;
    }

    return sql<boolean>`${rhs} = ANY(${lhs})`;
  }

  if (filter._containsArr) {
    let rhs: Expression<string[] | null> = sql.val(filter._containsArr._value);

    if (filter._containsArr._ignoreCase) {
      lhs = pgFn('public.to_uppercase_array', [lhs]);
      rhs = pgFn('public.to_uppercase_array', [rhs]);
    }

    return sql<boolean>`${lhs} @> ${rhs}`;
  }

  if (filter._containedBy) {
    let rhs: Expression<string[] | null> = sql.val(filter._containedBy._value);

    if (filter._containedBy._ignoreCase) {
      lhs = pgFn('public.to_uppercase_array', [lhs]);
      rhs = pgFn('public.to_uppercase_array', [rhs]);
    }

    return sql<boolean>`${lhs} <@ ${rhs}`;
  }

  if (filter._overlaps) {
    let rhs: Expression<string[] | null> = sql.val(filter._overlaps._value);

    if (filter._overlaps._ignoreCase) {
      lhs = pgFn('public.to_uppercase_array', [lhs]);
      rhs = pgFn('public.to_uppercase_array', [rhs]);
    }

    return sql<boolean>`${lhs} && ${rhs}`;
  }

  // Default for when filter is an empty object
  return sql.val(true);
}
