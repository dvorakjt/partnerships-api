import { CodegenConfig } from '@graphql-codegen/cli';
import { GQLARRConfig } from 'gqlarr';

const gqlarrConfig: GQLARRConfig = {
  imports: {},
  types: {
    DateTime: 'Date',
    BigInt: 'bigint',
  },
};

const config: CodegenConfig = {
  overwrite: true,
  schema: './src/graphql/**/*.graphql',
  generates: {
    'src/graphql/gqlarr.ts': {
      plugins: ['gqlarr'],
    },
  },
  config: gqlarrConfig,
};

export default config;
