import type { Resolvers } from '../../model/graphql';
import type { Database } from '../../db';

import { DateTimeResolver, BigIntResolver } from 'graphql-scalars';
import { location, locations, locationCount } from './functions/location';
import { partner, partners, partnerCount } from './functions/partner';
import { reward, rewards, rewardCount, categories } from './functions/reward';
import { languages } from './functions/language';
import { retrieveVoucher } from './voucher';
import { GraphQLScalarType } from 'graphql';

export function createResolvers(db: Database): Resolvers & {
  DateTime: GraphQLScalarType<Date, Date>;
  BigInt: GraphQLScalarType<number | bigint, string | number | bigint>;
} {
  return {
    DateTime: DateTimeResolver,
    BigInt: BigIntResolver,
    Query: {
      location: location(db),
      locations: locations(db),
      locationCount: locationCount(db),
      partner: partner(db),
      partners: partners(db),
      partnerCount: partnerCount(db),
      reward: reward(db),
      rewards: rewards(db),
      rewardCount: rewardCount(db),
      categories: categories(db),
      languages: languages(db),
    },
    Mutation: {
      retrieveVoucher,
    },
  };
}
