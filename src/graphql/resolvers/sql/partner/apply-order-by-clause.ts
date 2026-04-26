import { SelectQueryBuilder, sql } from 'kysely';
import {
  PartnerOrderByCriteria,
  SortOptions,
  SortOrder,
} from '../../../../model/graphql';
import { DB } from '../../../../model/db';

export function applyOrderByClause(
  qb: SelectQueryBuilder<DB, 'public.active_partner', any>,
  orderByClauses: PartnerOrderByCriteria[] = [],
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

    if (clause.translatedDetails) {
      const orderByTranslatedDetailsField = (
        field: keyof DB['public.partner_details_translation'],
        sortOptions: SortOptions,
      ) => {
        return builder.orderBy(
          eb =>
            sql`
              ${eb
                .selectFrom('public.partner_details_translation')
                .select(field)
                .where(eb =>
                  eb.and([
                    eb('partner_id', '=', eb.ref('public.active_partner.id')),
                    eb(
                      'language_tag',
                      '=',
                      clause.translatedDetails!._languageTag,
                    ),
                  ]),
                )
                .limit(1)}
              ${sql.raw(sortOptions._order === SortOrder.ASC ? 'ASC' : 'DESC')}
              ${sql.raw(sortOptions._nullsLast ? 'NULLS LAST' : 'NULLS FIRST')}
            `,
        );
      };

      if (clause.translatedDetails._orderBy.name) {
        return orderByTranslatedDetailsField(
          'name',
          clause.translatedDetails._orderBy.name,
        );
      }

      if (clause.translatedDetails._orderBy.description) {
        return orderByTranslatedDetailsField(
          'description',
          clause.translatedDetails._orderBy.description,
        );
      }

      if (clause.translatedDetails._orderBy.motivation) {
        return orderByTranslatedDetailsField(
          'motivation',
          clause.translatedDetails._orderBy.motivation,
        );
      }

      if (clause.translatedDetails._orderBy.logoUrl) {
        return orderByTranslatedDetailsField(
          'logo_url',
          clause.translatedDetails._orderBy.logoUrl,
        );
      }

      if (clause.translatedDetails._orderBy.webAddressUrl) {
        return orderByTranslatedDetailsField(
          'web_address_url',
          clause.translatedDetails._orderBy.webAddressUrl,
        );
      }

      if (clause.translatedDetails._orderBy.webAddressText) {
        return orderByTranslatedDetailsField(
          'web_address_text',
          clause.translatedDetails._orderBy.webAddressText,
        );
      }
    }

    return builder;
  }, qb);
}
