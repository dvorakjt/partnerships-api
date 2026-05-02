import 'dotenv/config';
import path from 'node:path';
import {
  introspeqlKysely,
  type IntrospeqlKyselyConfig,
} from 'introspeql-kysely';

const outFile = '/db/types/generated.ts';

const config: IntrospeqlKyselyConfig = {
  dbConnectionParams: {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: +process.env.DB_PORT!,
    database: process.env.DB_NAME,
  },
  schemas: ['public', 'pg_catalog'],
  outFile: path.join(import.meta.dirname, '..' + outFile),
  tables: {
    mode: 'exclusive',
  },
  views: {
    mode: 'exclusive',
  },
  materializedViews: {
    mode: 'exclusive',
  },
  functions: {
    mode: 'exclusive',
    includeFunctions: [
      {
        schema: 'pg_catalog',
        name: 'array_sort',
      },
    ],
  },
  header: "import { Point } from './point';",
  types: {
    'pg_catalog.any': 'any',
    'pg_catalog.anyarray': 'any[]',
    'pg_catalog.int8': 'bigint',
    'public.geography': 'Point',
    'public.reward': "DB['public.reward']",
  },
};

generateTypes();

async function generateTypes() {
  await introspeqlKysely(config);
  console.log('Type definition file created at src/' + outFile);
}
