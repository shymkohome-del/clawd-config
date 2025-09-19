import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'swap_contract.g.dart';

/// Swap contract status enumeration
@JsonEnum()
enum SwapContractStatus {
  @JsonValue('initiated')
  initiated,
  @JsonValue('locked')
  locked,
  @JsonValue('completed')
  completed,
  @JsonValue('refunded')
  refunded,
  @JsonValue('expired')
  expired,
}

/// Swap contract role enumeration
@JsonEnum()
enum SwapRole {
  @JsonValue('buyer')
  buyer,
  @JsonValue('seller')
  seller,
}

/// Cryptocurrency type enumeration
@JsonEnum()
enum CryptoType {
  @JsonValue('BTC')
  btc,
  @JsonValue('ETH')
  eth,
  @JsonValue('ICP')
  icp,
  @JsonValue('USDT')
  usdt,
  @JsonValue('USDC')
  usdc,
}

/// Swap contract model representing an HTLC (Hashed Timelock Contract)
@JsonSerializable()
class SwapContract extends Equatable {
  final String id;
  final String listingId;
  final String buyer;
  final String seller;
  final CryptoType cryptoAsset;
  final BigInt amount;
  final BigInt priceInUsd;
  final List<int> secretHash;
  final BigInt lockTime;
  final SwapContractStatus status;
  final BigInt createdAt;
  final BigInt? buyerDeposit;
  final BigInt? sellerDeposit;

  const SwapContract({
    required this.id,
    required this.listingId,
    required this.buyer,
    required this.seller,
    required this.cryptoAsset,
    required this.amount,
    required this.priceInUsd,
    required this.secretHash,
    required this.lockTime,
    required this.status,
    required this.createdAt,
    this.buyerDeposit,
    this.sellerDeposit,
  });

  factory SwapContract.fromJson(Map<String, dynamic> json) =>
      _$SwapContractFromJson(json);

  Map<String, dynamic> toJson() => _$SwapContractToJson(this);

  /// Create a copy of this swap contract with updated fields
  SwapContract copyWith({
    String? id,
    String? listingId,
    String? buyer,
    String? seller,
    CryptoType? cryptoAsset,
    BigInt? amount,
    BigInt? priceInUsd,
    List<int>? secretHash,
    BigInt? lockTime,
    SwapContractStatus? status,
    BigInt? createdAt,
    BigInt? buyerDeposit,
    BigInt? sellerDeposit,
  }) {
    return SwapContract(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      cryptoAsset: cryptoAsset ?? this.cryptoAsset,
      amount: amount ?? this.amount,
      priceInUsd: priceInUsd ?? this.priceInUsd,
      secretHash: secretHash ?? this.secretHash,
      lockTime: lockTime ?? this.lockTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      buyerDeposit: buyerDeposit ?? this.buyerDeposit,
      sellerDeposit: sellerDeposit ?? this.sellerDeposit,
    );
  }

  /// Get the lock time timestamp for display
  DateTime get lockTimeDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt.toInt() + lockTime.toInt());

  /// Check if the swap has expired
  bool get isExpired => DateTime.now().isAfter(lockTimeDateTime);

  /// Get the remaining time until lock time expires
  Duration get remainingTime {
    final now = DateTime.now();
    final lockTimeDate = lockTimeDateTime;
    return now.isAfter(lockTimeDate)
        ? Duration.zero
        : lockTimeDate.difference(now);
  }

  /// Check if the swap is ready for completion
  bool get isReadyForCompletion =>
      status == SwapContractStatus.locked &&
      buyerDeposit != null &&
      sellerDeposit != null;

  /// Check if the swap can be refunded
  bool get canBeRefunded =>
      (status == SwapContractStatus.initiated ||
          status == SwapContractStatus.locked) &&
      isExpired;

  @override
  List<Object?> get props => [
    id,
    listingId,
    buyer,
    seller,
    cryptoAsset,
    amount,
    priceInUsd,
    secretHash,
    lockTime,
    status,
    createdAt,
    buyerDeposit,
    sellerDeposit,
  ];
}

/// Request model for initiating a swap
@JsonSerializable()
class InitiateSwapRequest {
  final String listingId;
  final CryptoType cryptoAsset;
  final BigInt amount;
  final BigInt priceInUsd;
  final int lockTimeHours;

  const InitiateSwapRequest({
    required this.listingId,
    required this.cryptoAsset,
    required this.amount,
    required this.priceInUsd,
    required this.lockTimeHours,
  });

  factory InitiateSwapRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateSwapRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InitiateSwapRequestToJson(this);
}

/// Response model for swap initiation
@JsonSerializable()
class InitiateSwapResponse {
  final SwapContract contract;
  final String secret; // Only returned to initiator for safekeeping

  const InitiateSwapResponse({required this.contract, required this.secret});

  factory InitiateSwapResponse.fromJson(Map<String, dynamic> json) =>
      _$InitiateSwapResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InitiateSwapResponseToJson(this);
}

/// Model for swap timeline events
@JsonSerializable()
class SwapTimelineEvent {
  final String id;
  final String swapId;
  final String title;
  final String description;
  final DateTime timestamp;
  final SwapContractStatus? status;

  const SwapTimelineEvent({
    required this.id,
    required this.swapId,
    required this.title,
    required this.description,
    required this.timestamp,
    this.status,
  });

  factory SwapTimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$SwapTimelineEventFromJson(json);

  Map<String, dynamic> toJson() => _$SwapTimelineEventToJson(this);
}
