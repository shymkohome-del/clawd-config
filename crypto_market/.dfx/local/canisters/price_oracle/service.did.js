export const idlFactory = ({ IDL }) => {
  const PriceResult = IDL.Variant({ 'ok' : IDL.Float64, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'getPrice' : IDL.Func([IDL.Text], [PriceResult], ['query']),
    'healthCheck' : IDL.Func([], [IDL.Bool], ['query']),
    'updatePrice' : IDL.Func([IDL.Text, IDL.Float64], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };
