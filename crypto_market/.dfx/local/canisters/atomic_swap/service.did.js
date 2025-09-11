export const idlFactory = ({ IDL }) => {
  const SwapResult = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  return IDL.Service({
    'healthCheck' : IDL.Func([], [IDL.Bool], ['query']),
    'initiateSwap' : IDL.Func([IDL.Nat, IDL.Text], [SwapResult], []),
  });
};
export const init = ({ IDL }) => { return []; };
