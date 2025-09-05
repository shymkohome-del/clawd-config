export const idlFactory = ({ IDL }) => {
  const Listing = IDL.Record({
    'id' : IDL.Text,
    'title' : IDL.Text,
    'createdAt' : IDL.Int,
    'description' : IDL.Text,
    'seller' : IDL.Principal,
    'price' : IDL.Nat,
  });
  const ListingResult = IDL.Variant({ 'ok' : Listing, 'err' : IDL.Text });
  return IDL.Service({
    'createListing' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Nat],
        [ListingResult],
        [],
      ),
    'getListings' : IDL.Func([], [IDL.Vec(Listing)], ['query']),
    'healthCheck' : IDL.Func([], [IDL.Bool], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
