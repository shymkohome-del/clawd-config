import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type SwapResult = { 'ok' : string } |
  { 'err' : string };
export interface _SERVICE {
  'healthCheck' : ActorMethod<[], boolean>,
  'initiateSwap' : ActorMethod<[bigint, string], SwapResult>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
