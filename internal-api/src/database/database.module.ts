import { Global, Module } from '@nestjs/common';
import { Kysely, PostgresDialect } from 'kysely';
import { Pool } from 'pg';
import type { DB } from './db.types';

export const DB_TOKEN = Symbol('KYSELY_DB');

export type KyselyDB = Kysely<DB>;

@Global()
@Module({
  providers: [
    {
      provide: DB_TOKEN,
      useFactory: (): KyselyDB =>
        new Kysely<DB>({
          dialect: new PostgresDialect({
            pool: new Pool({
              user: process.env.DB_USER,
              password: process.env.DB_PASSWORD,
              host: process.env.DB_HOST,
              port: Number(process.env.DB_PORT),
              database: process.env.DB_NAME,
              max: 10,
            }),
          }),
        }),
    },
  ],
  exports: [DB_TOKEN],
})
export class DatabaseModule {}
