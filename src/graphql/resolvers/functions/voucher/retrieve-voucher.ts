import type { AppContext } from '../../../app-context';
import type { MutationRetrieveVoucherResolver } from '../../../gqlarr';

export const retrieveVoucher: MutationRetrieveVoucherResolver<AppContext> = (
  _parent,
  _args,
  context,
  info,
) => {
  // Should deduct 1 from voucher stubs that have counter
  throw new Error('Not implemented');
};
