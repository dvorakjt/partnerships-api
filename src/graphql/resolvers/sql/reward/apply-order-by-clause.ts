import { SelectQueryBuilder, sql } from 'kysely';
import { pgFn } from '../../../../db';
import { RewardOrderByCriteria, SortOrder } from '../../../../model/graphql';
import { DBWithAvailableRewardTable } from './create-select-statement';
import { applyOrderByClause as applyPartnerOrderByClause } from '../partner/apply-order-by-clause';

export function applyOrderByClause(
  qb: SelectQueryBuilder<
    DBWithAvailableRewardTable,
    'available_reward' | 'public.active_partner',
    any
  >,
  orderByClauses: RewardOrderByCriteria[] = [],
) {
  return orderByClauses.reduce((builder, clause) => {
    if (clause.id) {
      return builder.orderBy(
        eb =>
          sql`
            ${eb.ref('id')}
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
      return applyPartnerOrderByClause(
        builder.innerJoin(
          'public.active_partner',
          'partner_id',
          'public.active_partner.id',
        ),
        [clause.partner],
      );
    }

    return builder;
  }, qb);
}
