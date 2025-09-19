import 'package:json_annotation/json_annotation.dart';

part 'price_conversion.g.dart';

/// Price conversion error types
@JsonEnum()
enum PriceConversionError {
  @JsonValue('oracle_unavailable')
  oracleUnavailable,
  @JsonValue('invalid_crypto_type')
  invalidCryptoType,
  @JsonValue('price_too_stale')
  priceTooStale,
  @JsonValue('conversion_failed')
  conversionFailed,
  @JsonValue('network_error')
  networkError,
}

/// Price conversion response from oracle
@JsonSerializable()
class PriceConversionResponse {
  final double cryptoAmount;
  final double exchangeRate;
  final int timestamp;
  final String cryptoType;
  final int stalenessThresholdMs;

  const PriceConversionResponse({
    required this.cryptoAmount,
    required this.exchangeRate,
    required this.timestamp,
    required this.cryptoType,
    required this.stalenessThresholdMs,
  });

  factory PriceConversionResponse.fromJson(Map<String, dynamic> json) =>
      _$PriceConversionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PriceConversionResponseToJson(this);

  /// Check if the price is stale based on current time
  bool get isStale {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) > stalenessThresholdMs;
  }

  /// Get the age of the price data in milliseconds
  int get ageMs {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp;
  }

  /// Get formatted timestamp for display
  DateTime get timestampDateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);

  /// Create a copy with updated fields
  PriceConversionResponse copyWith({
    double? cryptoAmount,
    double? exchangeRate,
    int? timestamp,
    String? cryptoType,
    int? stalenessThresholdMs,
  }) {
    return PriceConversionResponse(
      cryptoAmount: cryptoAmount ?? this.cryptoAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      timestamp: timestamp ?? this.timestamp,
      cryptoType: cryptoType ?? this.cryptoType,
      stalenessThresholdMs: stalenessThresholdMs ?? this.stalenessThresholdMs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PriceConversionResponse) return false;
    return cryptoAmount == other.cryptoAmount &&
        exchangeRate == other.exchangeRate &&
        timestamp == other.timestamp &&
        cryptoType == other.cryptoType &&
        stalenessThresholdMs == other.stalenessThresholdMs;
  }

  @override
  int get hashCode {
    return Object.hash(
      cryptoAmount,
      exchangeRate,
      timestamp,
      cryptoType,
      stalenessThresholdMs,
    );
  }
}
