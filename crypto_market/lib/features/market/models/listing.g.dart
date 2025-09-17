// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Listing _$ListingFromJson(Map<String, dynamic> json) => Listing(
id: Listing._idFromJson(json['id']),
  seller: json['seller'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  priceUSD: (json['priceUSD'] as num).toInt(),
  cryptoType: json['cryptoType'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  category: json['category'] as String,
  condition: $enumDecode(_$ListingConditionEnumMap, json['condition']),
  location: json['location'] as String,
  shippingOptions: (json['shippingOptions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$ListingStatusEnumMap, json['status']),
  createdAt: (json['createdAt'] as num).toInt(),
  updatedAt: (json['updatedAt'] as num).toInt(),
);

Map<String, dynamic> _$ListingToJson(Listing instance) => <String, dynamic>{
'id': Listing._idToJson(instance.id),
  'seller': instance.seller,
  'title': instance.title,
  'description': instance.description,
  'priceUSD': instance.priceUSD,
  'cryptoType': instance.cryptoType,
  'images': instance.images,
  'category': instance.category,
  'condition': _$ListingConditionEnumMap[instance.condition]!,
  'location': instance.location,
  'shippingOptions': instance.shippingOptions,
  'status': _$ListingStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$ListingConditionEnumMap = {
  ListingCondition.newCondition: 'new',
  ListingCondition.used: 'used',
  ListingCondition.refurbished: 'refurbished',
};

const _$ListingStatusEnumMap = {
  ListingStatus.active: 'active',
  ListingStatus.pending: 'pending',
  ListingStatus.sold: 'sold',
  ListingStatus.cancelled: 'cancelled',
};
