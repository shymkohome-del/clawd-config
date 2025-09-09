export const idlFactory = ({ IDL }) => {
  const User = IDL.Record({
    'id' : IDL.Principal,
    'username' : IDL.Text,
    'createdAt' : IDL.Int,
    'email' : IDL.Text,
  });
  const RegisterResult = IDL.Variant({ 'ok' : User, 'err' : IDL.Text });
  return IDL.Service({
    'getUser' : IDL.Func([IDL.Principal], [IDL.Opt(User)], ['query']),
    'healthCheck' : IDL.Func([], [IDL.Bool], ['query']),
    'register' : IDL.Func([IDL.Text, IDL.Text], [RegisterResult], []),
  });
};
export const init = ({ IDL }) => { return []; };
