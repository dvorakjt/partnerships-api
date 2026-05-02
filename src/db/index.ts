import { Kysely, PostgresDialect } from 'kysely';
import type { Pool } from 'pg';
import { DB, pgFn } from './types';

export * from './types/set-type-parsers';

export type Database = Kysely<DB>;

export function createDb(pool: Pool): Database {
  return new Kysely<DB>({
    dialect: new PostgresDialect({
      pool,
    }),
  });
}

export { pgFn };
