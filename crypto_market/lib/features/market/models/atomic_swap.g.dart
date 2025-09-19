// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atomic_swap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtomicSwap _$AtomicSwapFromJson(Map<String, dynamic> json) => AtomicSwap(
  id: (json['id'] as num).toInt(),
  listingId: (json['listingId'] as num).toInt(),
  buyer: json['buyer'] as String,
  seller: json['seller'] as String,
  secretHash: (json['secretHash'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  amount: BigInt.parse(json['amount'] as String),
  cryptoType: json['cryptoType'] as String,
  timeout: BigInt.parse(json['timeout'] as String),
  status: $enumDecode(_$AtomicSwapStatusEnumMap, json['status']),
  createdAt: BigInt.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AtomicSwapToJson(AtomicSwap instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listingId': instance.listingId,
      'buyer': instance.buyer,
      'seller': instance.seller,
      'secretHash': instance.secretHash,
      'amount': instance.amount.toString(),
      'cryptoType': instance.cryptoType,
      'timeout': instance.timeout.toString(),
      'status': _$AtomicSwapStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toString(),
    };

const _$AtomicSwapStatusEnumMap = {
  AtomicSwapStatus.pending: 'pending',
  AtomicSwapStatus.completed: 'completed',
  AtomicSwapStatus.refunded: 'refunded',
  AtomicSwapStatus.expired: 'expired',
};
