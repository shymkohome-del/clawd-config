// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_conversion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceConversionResponse _$PriceConversionResponseFromJson(
  Map<String, dynamic> json,
) => PriceConversionResponse(
  cryptoAmount: (json['cryptoAmount'] as num).toDouble(),
  exchangeRate: (json['exchangeRate'] as num).toDouble(),
  timestamp: (json['timestamp'] as num).toInt(),
  cryptoType: json['cryptoType'] as String,
  stalenessThresholdMs: (json['stalenessThresholdMs'] as num).toInt(),
);

Map<String, dynamic> _$PriceConversionResponseToJson(
  PriceConversionResponse instance,
) => <String, dynamic>{
  'cryptoAmount': instance.cryptoAmount,
  'exchangeRate': instance.exchangeRate,
  'timestamp': instance.timestamp,
  'cryptoType': instance.cryptoType,
  'stalenessThresholdMs': instance.stalenessThresholdMs,
};
