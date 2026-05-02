import { type Expression, sql } from 'kysely';
import type { BigIntFilter } from '../../../gqlarr';

export function createBigIntFilterExpression(
  lhs: Expression<bigint | null>,
  filter: BigIntFilter,
): Expression<boolean> {
  if (typeof filter._eq === 'bigint') {
    return sql`${lhs} = ${filter._eq}`;
  }

  if (filter._eq === null) {
    return sql<boolean>`${lhs} IS NULL`;
  }

  if (typeof filter._neq === 'bigint') {
    return sql<boolean>`${lhs} != ${filter._neq}`;
  }

  if (filter._neq === null) {
    return sql<boolean>`${lhs} IS NOT NULL`;
  }

  if (typeof filter._gt === 'bigint') {
    return sql<boolean>`${lhs} > ${filter._gt}`;
  }

  if (typeof filter._gte === 'bigint') {
    return sql<boolean>`${lhs} >= ${filter._gte}`;
  }

  if (typeof filter._lt === 'bigint') {
    return sql<boolean>`${lhs} < ${filter._lt}`;
  }

  if (typeof filter._lte === 'bigint') {
    return sql<boolean>`${lhs} <= ${filter._lte}`;
  }

  // Default for when filter is an empty object
  return sql.val(true);
}
