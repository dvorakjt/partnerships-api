import 'dotenv/config';
import 'json-bigint-patch';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@as-integrations/express5';
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer';
import express from 'express';
import http from 'http';
import cors from 'cors';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse as parseContentType } from 'content-type';
import { defaultFieldResolver } from 'graphql';
import { Pool } from 'pg';
import { createResolvers, typeDefs } from './graphql';
import { setCustomTypeParsers, parseTimeZoneHeader } from './util';
import { AppContext } from './graphql';
import { createDb } from './db';

await setCustomTypeParsers();

const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: +process.env.DB_PORT!,
  database: process.env.DB_NAME,
  min: 2,
  max: 10,
});

const clients = [await pool.connect(), await pool.connect()];

clients.forEach(client => client.release());

const db = createDb(pool);
const resolvers = createResolvers(db);

const app = express();
const httpServer = http.createServer(app);
const publicDir = fileURLToPath(new URL('./public', import.meta.url));

app.use(
  express.static(publicDir, {
    fallthrough: true,
  }),
);

const aliasAwareFieldResolver = (
  source: unknown,
  args: any,
  context: AppContext,
  info: any,
) => {
  if (source && typeof source === 'object') {
    const responseKey = String(info.path.key);
    if (Object.hasOwn(source, responseKey)) {
      return (source as Record<string, unknown>)[responseKey];
    }
  }

  return defaultFieldResolver(source as any, args, context, info);
};

const server = new ApolloServer<AppContext>({
  typeDefs,
  resolvers,
  fieldResolver: aliasAwareFieldResolver,
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
});

await server.start();

const validCharset = /^utf-(8|((16|32)(le|be)?))$/i;
app.use(
  '/graphql',
  cors<cors.CorsRequest>(),
  express.json({
    verify(req) {
      const charset = parseContentType(req).parameters.charset || 'utf-8';
      if (!charset.match(validCharset)) {
        throw Object.assign(
          new Error(`unsupported charset "${charset.toUpperCase()}"`),
          {
            status: 415,
            name: 'UnsupportedMediaTypeError',
            charset,
            type: 'charset.unsupported',
          },
        );
      }
    },
  }),
  expressMiddleware(server, {
    context: async ({ req }) => ({
      timezone: parseTimeZoneHeader(req.headers['time-zone']),
    }),
  }),
);

await new Promise<void>(resolve => httpServer.listen({ port: 4000 }, resolve));

console.log(`🚀 Server ready at http://localhost:4000/graphql`);
