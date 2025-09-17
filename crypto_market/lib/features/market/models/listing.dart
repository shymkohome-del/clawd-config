import 'package:json_annotation/json_annotation.dart';

part 'listing.g.dart';

/// Listing condition enumeration
enum ListingCondition {
  @JsonValue('new')
  newCondition,
  @JsonValue('used')
  used,
  @JsonValue('refurbished')
  refurbished,
}

/// Listing status enumeration
enum ListingStatus {
  @JsonValue('active')
  active,
  @JsonValue('pending')
  pending,
  @JsonValue('sold')
  sold,
  @JsonValue('cancelled')
  cancelled,
}

/// Listing model representing marketplace items for sale
@JsonSerializable()
class Listing {
  @JsonKey(fromJson: Listing._idFromJson, toJson: Listing._idToJson)
  final String id;
  final String seller; // Principal text representation
  final String title;
  final String description;
  final int priceUSD;
  final String cryptoType;
  final List<String> images; // IPFS hashes
  final String category;
  final ListingCondition condition;
  final String location;
  final List<String> shippingOptions;
  final ListingStatus status;
  final int createdAt;
  final int updatedAt;

  const Listing({
    required this.id,
    required this.seller,
    required this.title,
    required this.description,
    required this.priceUSD,
    required this.cryptoType,
    required this.images,
    required this.category,
    required this.condition,
    required this.location,
    required this.shippingOptions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  Map<String, dynamic> toJson() => _$ListingToJson(this);

  static String _idFromJson(Object? value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static String _idToJson(String value) => value;

  /// Create a copy of this listing with updated fields
  Listing copyWith({
    String? id,
    String? seller,
    String? title,
    String? description,
    int? priceUSD,
    String? cryptoType,
    List<String>? images,
    String? category,
    ListingCondition? condition,
    String? location,
    List<String>? shippingOptions,
    ListingStatus? status,
    int? createdAt,
    int? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      seller: seller ?? this.seller,
      title: title ?? this.title,
      description: description ?? this.description,
      priceUSD: priceUSD ?? this.priceUSD,
      cryptoType: cryptoType ?? this.cryptoType,
      images: images ?? this.images,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      shippingOptions: shippingOptions ?? this.shippingOptions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Listing) return false;
    return id == other.id &&
        seller == other.seller &&
        title == other.title &&
        description == other.description &&
        priceUSD == other.priceUSD &&
        cryptoType == other.cryptoType &&
        images.length == other.images.length &&
        category == other.category &&
        condition == other.condition &&
        location == other.location &&
        shippingOptions.length == other.shippingOptions.length &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      seller,
      title,
      description,
      priceUSD,
      cryptoType,
      images,
      category,
      condition,
      location,
      shippingOptions,
      status,
      createdAt,
      updatedAt,
    );
  }
}
