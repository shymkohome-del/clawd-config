import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type PriceResult = { 'ok' : number } |
  { 'err' : string };
export type Result = { 'ok' : null } |
  { 'err' : string };
export interface _SERVICE {
  'getPrice' : ActorMethod<[string], PriceResult>,
  'healthCheck' : ActorMethod<[], boolean>,
  'updatePrice' : ActorMethod<[string, number], Result>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
