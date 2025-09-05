import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Listing {
  'id' : string,
  'title' : string,
  'createdAt' : bigint,
  'description' : string,
  'seller' : Principal,
  'price' : bigint,
}
export type ListingResult = { 'ok' : Listing } |
  { 'err' : string };
export interface _SERVICE {
  'createListing' : ActorMethod<[string, string, bigint], ListingResult>,
  'getListings' : ActorMethod<[], Array<Listing>>,
  'healthCheck' : ActorMethod<[], boolean>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
