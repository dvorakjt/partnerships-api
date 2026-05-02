import { Point } from './point';

import {
  sql,
  type Expression,
  type RawBuilder,
  type Generated,
  type GeneratedAlways,
} from "kysely";

export interface DB {
  "public.active_partner": {
    created_at: Generated<Date>;
    id: GeneratedAlways<number>;
    is_active: Generated<boolean>;
    updated_at: Generated<Date>;
  };
  "public.active_partner_location": {
    coordinates: Point;
    created_at: Generated<Date>;
    id: GeneratedAlways<bigint>;
    partner_id: number;
    updated_at: Generated<Date>;
  };
  "public.base_entity": {
    created_at: Generated<Date>;
    updated_at: Generated<Date>;
  };
  "public.base_voucher": {
    created_at: Generated<Date>;
    redeemable_until: Date;
    updated_at: Generated<Date>;
  };
  "public.base_voucher_stub": {
    created_at: Generated<Date>;
    redeemable_for: string;
    redeemable_until_exact: Date;
    redeemable_until_local: Date;
    updated_at: Generated<Date>;
    vouchers_remaining: number;
  };
  "public.category": {
    created_at: Generated<Date>;
    id: GeneratedAlways<number>;
    updated_at: Generated<Date>;
  };
  "public.category_translation": {
    category_id: number;
    category_name: string;
    created_at: Generated<Date>;
    language_tag: string;
    updated_at: Generated<Date>;
  };
  "public.code_based_voucher_value": {
    created_at: Generated<Date>;
    id: GeneratedAlways<bigint>;
    multiple_use_voucher_id: number;
    redemption_code: string;
    single_use_voucher_id: bigint;
    updated_at: Generated<Date>;
  };
  "public.code_based_voucher_value_details_translation": {
    code_based_voucher_value_id: bigint;
    created_at: Generated<Date>;
    instructions: string;
    language_tag: string;
    updated_at: Generated<Date>;
  };
  "public.language": {
    created_at: Generated<Date>;
    /** The name of the language in English. */
    language_name_en: string;
    /** The native name of the language. */
    language_name_native: string;
    language_tag: string;
    updated_at: Generated<Date>;
  };
  "public.link_based_voucher_value": {
    created_at: Generated<Date>;
    id: GeneratedAlways<bigint>;
    multiple_use_voucher_id: number;
    single_use_voucher_id: bigint;
    updated_at: Generated<Date>;
  };
  "public.link_based_voucher_value_details_translation": {
    created_at: Generated<Date>;
    instructions: string;
    language_tag: string;
    link_based_voucher_value_id: bigint;
    redemption_link_text: string;
    redemption_link_url: string;
    updated_at: Generated<Date>;
  };
  "public.location": {
    coordinates: Point;
    created_at: Generated<Date>;
    id: GeneratedAlways<bigint>;
    partner_id: number;
    updated_at: Generated<Date>;
  };
  "public.manual_voucher_stub": {
    created_at: Generated<Date>;
    id: GeneratedAlways<number>;
    redeemable_for: string;
    redeemable_until_exact: Date;
    redeemable_until_local: Date;
    reward_id: string;
    updated_at: Generated<Date>;
    vouchers_remaining: number;
  };
  "public.manual_voucher_stub_details_translation": {
    created_at: Generated<Date>;
    instructions: string;
    language_tag: string;
    manual_voucher_stub_id: number;
    updated_at: Generated<Date>;
  };
  "public.multiple_use_voucher": {
    created_at: Generated<Date>;
    has_usage_cap: boolean;
    id: GeneratedAlways<number>;
    redeemable_until: Date;
    reward_id: string;
    updated_at: Generated<Date>;
  };
  "public.on_demand_voucher_stub": {
    created_at: Generated<Date>;
    id: GeneratedAlways<number>;
    redeemable_for: string;
    redeemable_until_exact: Date;
    redeemable_until_local: Date;
    reward_id: string;
    updated_at: Generated<Date>;
    vouchers_remaining: number;
  };
  "public.partner": {
    created_at: Generated<Date>;
    id: GeneratedAlways<number>;
    is_active: Generated<boolean>;
    updated_at: Generated<Date>;
  };
  "public.partner_details_translation": {
    created_at: Generated<Date>;
    description: string;
    language_tag: string;
    logo_url: string;
    motivation: string;
    name: string;
    partner_id: number;
    updated_at: Generated<Date>;
    web_address_text: string;
    web_address_url: string;
  };
  "public.qr_code_based_voucher_value": {
    created_at: Generated<Date>;
    id: GeneratedAlways<bigint>;
    multiple_use_voucher_id: number;
    redemption_qr_code: string;
    single_use_voucher_id: bigint;
    updated_at: Generated<Date>;
  };
  "public.qr_code_based_voucher_value_details_translation": {
    created_at: Generated<Date>;
    instructions: string;
    language_tag: string;
    qr_code_based_voucher_value_id: bigint;
    updated_at: Generated<Date>;
  };
  "public.reward": {
    available_from_exact: Date;
    available_from_local: Date;
    available_until_exact: Date;
    available_until_local: Date;
    created_at: Generated<Date>;
    id: Generated<string>;
    partner_id: number;
    redemption_forums: ("ONLINE" | "IN_STORE")[];
    updated_at: Generated<Date>;
    voucher_type: "MULTIPLE_USE" | "SINGLE_USE" | "ON_DEMAND" | "MANUAL";
  };
  "public.reward_category": {
    category_id: number;
    created_at: Generated<Date>;
    reward_id: string;
    updated_at: Generated<Date>;
  };
  "public.reward_details_translation": {
    created_at: Generated<Date>;
    language_tag: string;
    long_description: string;
    reward_id: string;
    short_description: string;
    updated_at: Generated<Date>;
  };
  "public.single_use_voucher": {
    created_at: Generated<Date>;
    id: GeneratedAlways<bigint>;
    redeemable_until: Date;
    reward_id: string;
    updated_at: Generated<Date>;
  };
  "public.valid_reward": {
    available_from_exact: Date;
    available_from_local: Date;
    available_until_exact: Date;
    available_until_local: Date;
    created_at: Generated<Date>;
    id: Generated<string>;
    partner_id: number;
    redemption_forums: string;
    updated_at: Generated<Date>;
    voucher_type: "MULTIPLE_USE" | "SINGLE_USE" | "ON_DEMAND" | "MANUAL";
  };
  /**
   * A view that includes only manual voucher stubs that meet the following
   * conditions:
   *
   * - The voucher stub must have translated details in all supported languages
   */
  "public.v_valid_manual_voucher_stub": {
    created_at: Date;
    id: number;
    redeemable_for: string;
    redeemable_until_exact: Date;
    redeemable_until_local: Date;
    reward_id: string;
    updated_at: Date;
    vouchers_remaining: number;
  };
  /**
   * A view that includes only multiple-use vouchers that meet the following
   * conditions:
   *
   * - The voucher must have at minimum one code-based-, qr-code-based-, or
   *   link-based-value
   * - All values for the voucher must have translated details in all supported
   *   languages
   */
  "public.v_valid_multiple_use_voucher": {
    created_at: Date;
    has_usage_cap: boolean;
    id: number;
    redeemable_until: Date;
    reward_id: string;
    updated_at: Date;
  };
  /**
   * A view that includes only single-use vouchers that meet the following
   * conditions:
   *
   * - The voucher must have at minimum one code-based-, qr-code-based-, or
   *   link-based-value
   * - All values for the voucher must have translated details in all supported
   *   languages
   */
  "public.v_valid_single_use_voucher": {
    created_at: Date;
    id: bigint;
    redeemable_until: Date;
    reward_id: string;
    updated_at: Date;
  };
}

type PgFnNames =
  | "pg_catalog.array_sort"
  | "pg_catalog.jsonb_build_object"
  | "public.calc_distance_with_units"
  | "public.calc_earliest_future_expiration_date"
  | "public.convert_distance"
  | "public.get_available_rewards_in_timezone"
  | "public.get_latitude"
  | "public.get_longitude"
  | "public.get_translated_reward_categories"
  | "public.has_usage_or_quantity_limit"
  | "public.make_geographic_point"
  | "public.st_dwithin"
  | "public.to_uppercase_array";

type PgFnParams<T extends PgFnNames> = T extends "pg_catalog.array_sort"
  ?
      | [Expression<any[]>]
      | [Expression<any[]>, Expression<boolean>]
      | [Expression<any[]>, Expression<boolean>, Expression<boolean>]
  : T extends "pg_catalog.jsonb_build_object"
    ? [...Expression<any>[]]
    : T extends "public.calc_distance_with_units"
      ? [
          Expression<Point>,
          Expression<Point>,
          Expression<"METERS" | "KILOMETERS" | "MILES">,
        ]
      : T extends "public.calc_earliest_future_expiration_date"
        ? [Expression<string>, Expression<string>]
        : T extends "public.convert_distance"
          ? [
              Expression<number>,
              Expression<"METERS" | "KILOMETERS" | "MILES">,
              Expression<"METERS" | "KILOMETERS" | "MILES">,
            ]
          : T extends "public.get_available_rewards_in_timezone"
            ? [Expression<string>]
            : T extends "public.get_latitude"
              ? [Expression<Point>]
              : T extends "public.get_longitude"
                ? [Expression<Point>]
                : T extends "public.get_translated_reward_categories"
                  ? [Expression<string>, Expression<string>]
                  : T extends "public.has_usage_or_quantity_limit"
                    ? [Expression<string>]
                    : T extends "public.make_geographic_point"
                      ? [Expression<number>, Expression<number>]
                      : T extends "public.st_dwithin"
                        ?
                            | [
                                Expression<Point>,
                                Expression<Point>,
                                Expression<number>,
                              ]
                            | [
                                Expression<Point>,
                                Expression<Point>,
                                Expression<number>,
                                Expression<boolean>,
                              ]
                        : T extends "public.to_uppercase_array"
                          ? [Expression<string[] | null>]
                          : never;

type PgFnReturnTypes<
  T extends PgFnNames,
  V extends PgFnParams<T>,
> = T extends "pg_catalog.array_sort"
  ? V extends [Expression<any[]>]
    ? any[] | null
    : V extends [Expression<any[]>, Expression<boolean>]
      ? any[] | null
      : V extends [Expression<any[]>, Expression<boolean>, Expression<boolean>]
        ? any[] | null
        : never
  : T extends "pg_catalog.jsonb_build_object"
    ? V extends [...Expression<any>[]]
      ? object
      : never
    : T extends "public.calc_distance_with_units"
      ? V extends [
          Expression<Point>,
          Expression<Point>,
          Expression<"METERS" | "KILOMETERS" | "MILES">,
        ]
        ? number
        : never
      : T extends "public.calc_earliest_future_expiration_date"
        ? V extends [Expression<string>, Expression<string>]
          ? Date | null
          : never
        : T extends "public.convert_distance"
          ? V extends [
              Expression<number>,
              Expression<"METERS" | "KILOMETERS" | "MILES">,
              Expression<"METERS" | "KILOMETERS" | "MILES">,
            ]
            ? number
            : never
          : T extends "public.get_available_rewards_in_timezone"
            ? V extends [Expression<string>]
              ? DB["public.reward"]
              : never
            : T extends "public.get_latitude"
              ? V extends [Expression<Point>]
                ? number
                : never
              : T extends "public.get_longitude"
                ? V extends [Expression<Point>]
                  ? number
                  : never
                : T extends "public.get_translated_reward_categories"
                  ? V extends [Expression<string>, Expression<string>]
                    ? string[]
                    : never
                  : T extends "public.has_usage_or_quantity_limit"
                    ? V extends [Expression<string>]
                      ? boolean
                      : never
                    : T extends "public.make_geographic_point"
                      ? V extends [Expression<number>, Expression<number>]
                        ? Point
                        : never
                      : T extends "public.st_dwithin"
                        ? V extends [
                            Expression<Point>,
                            Expression<Point>,
                            Expression<number>,
                          ]
                          ? boolean
                          : V extends [
                                Expression<Point>,
                                Expression<Point>,
                                Expression<number>,
                                Expression<boolean>,
                              ]
                            ? boolean
                            : never
                        : T extends "public.to_uppercase_array"
                          ? V extends [Expression<string[] | null>]
                            ? string[] | null
                            : never
                          : never;

export function pgFn<T extends PgFnNames, V extends PgFnParams<T>>(
  fn: T,
  args: V,
): RawBuilder<PgFnReturnTypes<T, V>> {
  return sql<PgFnReturnTypes<T, V>>`${sql.raw(fn)}(${sql.join(args)})`;
}