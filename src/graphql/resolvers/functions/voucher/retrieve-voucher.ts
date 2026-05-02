import type { AppContext } from '../../../app-context';
import type { MutationRetrieveVoucherResolver } from '../../../gqlarr';

export const retrieveVoucher: MutationRetrieveVoucherResolver<AppContext> = (
  _parent,
  _args,
  context,
  info,
) => {
  throw new Error('Not implemented');
};
