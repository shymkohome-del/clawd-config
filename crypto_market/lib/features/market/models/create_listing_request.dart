import 'package:crypto_market/features/market/models/listing.dart';

/// Data Transfer Object for creating a new listing
class CreateListingRequest {
  final String title;
  final String description;
  final int priceUSD;
  final String cryptoType;
  final List<String> images;
  final String category;
  final ListingCondition condition;
  final String location;
  final List<String> shippingOptions;

  const CreateListingRequest({
    required this.title,
    required this.description,
    required this.priceUSD,
    required this.cryptoType,
    required this.images,
    required this.category,
    required this.condition,
    required this.location,
    required this.shippingOptions,
  });

  /// Convert to map for API calls
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priceUSD': priceUSD,
      'cryptoType': cryptoType,
      'images': images,
      'category': category,
      'condition': _conditionToString(condition),
      'location': location,
      'shippingOptions': shippingOptions,
    };
  }

  /// Convert ListingCondition enum to string
  String _conditionToString(ListingCondition condition) {
    switch (condition) {
      case ListingCondition.newCondition:
        return 'new';
      case ListingCondition.used:
        return 'used';
      case ListingCondition.refurbished:
        return 'refurbished';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateListingRequest) return false;
    return title == other.title &&
        description == other.description &&
        priceUSD == other.priceUSD &&
        cryptoType == other.cryptoType &&
        images.length == other.images.length &&
        category == other.category &&
        condition == other.condition &&
        location == other.location &&
        shippingOptions.length == other.shippingOptions.length;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      priceUSD,
      cryptoType,
      images,
      category,
      condition,
      location,
      shippingOptions,
    );
  }
}
