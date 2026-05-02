import { SelectQueryBuilder, sql } from 'kysely';
import { pgFn } from '../../../../db';
import { RewardOrderByCriteria, SortOrder } from '../../../gqlarr';
import { DBWithAvailableRewardTable } from './create-select-statement';

export function applyOrderByClause(
  qb: SelectQueryBuilder<DBWithAvailableRewardTable, 'available_reward', any>,
  orderByClauses: RewardOrderByCriteria[] = [],
) {
  return orderByClauses.reduce<
    SelectQueryBuilder<DBWithAvailableRewardTable, 'available_reward', any>
  >((builder, clause) => {
    if (clause.id) {
      return builder.orderBy(
        eb =>
          sql`
            ${eb.ref('available_reward.id')}
            ${sql.raw(clause.id!._order === SortOrder.ASC ? 'ASC' : 'DESC')}
            ${sql.raw(clause.id!._nullsLast ? 'NULLS LAST' : 'NULLS FIRST')}
          `,
      );
    }

    if (clause.translatedDetails?._orderBy.categories) {
      return builder.orderBy(
        eb =>
          sql`
            ${pgFn('public.get_translated_reward_categories', [
              eb.ref('available_reward.id'),
              eb.val(clause.translatedDetails?._languageTag),
            ])}
            ${sql.raw(
              (
                clause.translatedDetails!._orderBy.categories!._order ===
                  SortOrder.ASC
              ) ?
                'ASC'
              : 'DESC',
            )}
            ${sql.raw(
              clause.translatedDetails!._orderBy.categories!._nullsLast ?
                'NULLS LAST'
              : 'NULLS FIRST',
            )}`,
      );
    }

    if (clause.translatedDetails?._orderBy.shortDescription) {
      return builder.orderBy(eb => {
        const shortDescriptionExpression = eb
          .selectFrom('public.reward_details_translation')
          .select('short_description')
          .where(eb =>
            eb.and([
              eb('reward_id', '=', eb.ref('available_reward.id')),
              eb(
                'language_tag',
                '=',
                eb.val(clause.translatedDetails!._languageTag),
              ),
            ]),
          )
          .limit(1);

        return sql`
                ${shortDescriptionExpression}
                ${sql.raw(
                  (
                    clause.translatedDetails!._orderBy.shortDescription!
                      ._order === SortOrder.ASC
                  ) ?
                    'ASC'
                  : 'DESC',
                )}
                ${sql.raw(
                  (
                    clause.translatedDetails!._orderBy.shortDescription!
                      ._nullsLast
                  ) ?
                    'NULLS LAST'
                  : 'NULLS FIRST',
                )}
              `;
      });
    }

    if (clause.translatedDetails?._orderBy.longDescription) {
      return builder.orderBy(eb => {
        const longDescriptionExpression = eb
          .selectFrom('public.reward_details_translation')
          .select('long_description')
          .where(eb =>
            eb.and([
              eb('reward_id', '=', eb.ref('available_reward.id')),
              eb(
                'language_tag',
                '=',
                eb.val(clause.translatedDetails?._languageTag),
              ),
            ]),
          )
          .limit(1);

        return sql`
                ${longDescriptionExpression}
                ${sql.raw(
                  (
                    clause.translatedDetails!._orderBy.longDescription!
                      ._order === SortOrder.ASC
                  ) ?
                    'ASC'
                  : 'DESC',
                )}
                ${sql.raw(
                  (
                    clause.translatedDetails!._orderBy.longDescription!
                      ._nullsLast
                  ) ?
                    'NULLS LAST'
                  : 'NULLS FIRST',
                )}
              `;
      });
    }

    if (clause.partner) {
      if (clause.partner.id) {
        return builder.orderBy(
          eb =>
            sql`
              ${eb.ref('available_reward.partner_id')}
              ${sql.raw(clause.partner!.id!._order === SortOrder.ASC ? 'ASC' : 'DESC')}
              ${sql.raw(clause.partner!.id!._nullsLast ? 'NULLS LAST' : 'NULLS FIRST')}
            `,
        );
      }

      if (clause.partner.translatedDetails?._orderBy.name) {
        return builder.orderBy(eb => {
          const nameExpression = eb
            .selectFrom('public.partner_details_translation')
            .select('name')
            .where(eb =>
              eb.and([
                eb('partner_id', '=', eb.ref('available_reward.partner_id')),
                eb(
                  'language_tag',
                  '=',
                  eb.val(clause.partner!.translatedDetails!._languageTag),
                ),
              ]),
            )
            .limit(1);

          return sql`
            ${nameExpression}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.name!._order ===
                  SortOrder.ASC
              ) ?
                'ASC'
              : 'DESC',
            )}
            ${sql.raw(
              clause.partner!.translatedDetails!._orderBy.name!._nullsLast ?
                'NULLS LAST'
              : 'NULLS FIRST',
            )}
          `;
        });
      }

      if (clause.partner.translatedDetails?._orderBy.description) {
        return builder.orderBy(eb => {
          const descriptionExpression = eb
            .selectFrom('public.partner_details_translation')
            .select('description')
            .where(eb =>
              eb.and([
                eb('partner_id', '=', eb.ref('available_reward.partner_id')),
                eb(
                  'language_tag',
                  '=',
                  eb.val(clause.partner!.translatedDetails!._languageTag),
                ),
              ]),
            )
            .limit(1);

          return sql`
            ${descriptionExpression}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.description!
                  ._order === SortOrder.ASC
              ) ?
                'ASC'
              : 'DESC',
            )}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.description!
                  ._nullsLast
              ) ?
                'NULLS LAST'
              : 'NULLS FIRST',
            )}
          `;
        });
      }

      if (clause.partner.translatedDetails?._orderBy.motivation) {
        return builder.orderBy(eb => {
          const motivationExpression = eb
            .selectFrom('public.partner_details_translation')
            .select('motivation')
            .where(eb =>
              eb.and([
                eb('partner_id', '=', eb.ref('available_reward.partner_id')),
                eb(
                  'language_tag',
                  '=',
                  eb.val(clause.partner!.translatedDetails!._languageTag),
                ),
              ]),
            )
            .limit(1);

          return sql`
            ${motivationExpression}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.motivation!
                  ._order === SortOrder.ASC
              ) ?
                'ASC'
              : 'DESC',
            )}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.motivation!
                  ._nullsLast
              ) ?
                'NULLS LAST'
              : 'NULLS FIRST',
            )}
          `;
        });
      }

      if (clause.partner.translatedDetails?._orderBy.logoUrl) {
        return builder.orderBy(eb => {
          const logoExpression = eb
            .selectFrom('public.partner_details_translation')
            .select('logo_url')
            .where(eb =>
              eb.and([
                eb('partner_id', '=', eb.ref('available_reward.partner_id')),
                eb(
                  'language_tag',
                  '=',
                  eb.val(clause.partner!.translatedDetails!._languageTag),
                ),
              ]),
            )
            .limit(1);

          return sql`
            ${logoExpression}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.logoUrl!._order ===
                  SortOrder.ASC
              ) ?
                'ASC'
              : 'DESC',
            )}
            ${sql.raw(
              clause.partner!.translatedDetails!._orderBy.logoUrl!._nullsLast ?
                'NULLS LAST'
              : 'NULLS FIRST',
            )}
          `;
        });
      }

      if (clause.partner.translatedDetails?._orderBy.webAddressUrl) {
        return builder.orderBy(eb => {
          const webAddressUrlExpression = eb
            .selectFrom('public.partner_details_translation')
            .select('web_address_url')
            .where(eb =>
              eb.and([
                eb('partner_id', '=', eb.ref('available_reward.partner_id')),
                eb(
                  'language_tag',
                  '=',
                  eb.val(clause.partner!.translatedDetails!._languageTag),
                ),
              ]),
            )
            .limit(1);

          return sql`
            ${webAddressUrlExpression}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.webAddressUrl!
                  ._order === SortOrder.ASC
              ) ?
                'ASC'
              : 'DESC',
            )}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.webAddressUrl!
                  ._nullsLast
              ) ?
                'NULLS LAST'
              : 'NULLS FIRST',
            )}
          `;
        });
      }

      if (clause.partner.translatedDetails?._orderBy.webAddressText) {
        return builder.orderBy(eb => {
          const webAddressTextExpression = eb
            .selectFrom('public.partner_details_translation')
            .select('web_address_text')
            .where(eb =>
              eb.and([
                eb('partner_id', '=', eb.ref('available_reward.partner_id')),
                eb(
                  'language_tag',
                  '=',
                  eb.val(clause.partner!.translatedDetails!._languageTag),
                ),
              ]),
            )
            .limit(1);

          return sql`
            ${webAddressTextExpression}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.webAddressText!
                  ._order === SortOrder.ASC
              ) ?
                'ASC'
              : 'DESC',
            )}
            ${sql.raw(
              (
                clause.partner!.translatedDetails!._orderBy.webAddressText!
                  ._nullsLast
              ) ?
                'NULLS LAST'
              : 'NULLS FIRST',
            )}
          `;
        });
      }
    }

    return builder;
  }, qb);
}
