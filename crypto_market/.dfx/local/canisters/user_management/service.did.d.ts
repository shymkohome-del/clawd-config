import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type RegisterResult = { 'ok' : User } |
  { 'err' : string };
export interface User {
  'id' : Principal,
  'username' : string,
  'createdAt' : bigint,
  'email' : string,
}
export interface _SERVICE {
  'getUser' : ActorMethod<[Principal], [] | [User]>,
  'healthCheck' : ActorMethod<[], boolean>,
  'register' : ActorMethod<[string, string], RegisterResult>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
