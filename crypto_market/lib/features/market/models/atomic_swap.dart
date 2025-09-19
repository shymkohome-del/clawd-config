import 'package:json_annotation/json_annotation.dart';

part 'atomic_swap.g.dart';

/// Atomic swap status enumeration
@JsonEnum()
enum AtomicSwapStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('refunded')
  refunded,
  @JsonValue('expired')
  expired,
}

/// Atomic swap model representing a pending cryptocurrency transaction
@JsonSerializable()
class AtomicSwap {
  final int id;
  final int listingId;
  final String buyer;
  final String seller;
  final List<int> secretHash;
  final BigInt amount;
  final String cryptoType;
  final BigInt timeout;
  final AtomicSwapStatus status;
  final BigInt createdAt;

  const AtomicSwap({
    required this.id,
    required this.listingId,
    required this.buyer,
    required this.seller,
    required this.secretHash,
    required this.amount,
    required this.cryptoType,
    required this.timeout,
    required this.status,
    required this.createdAt,
  });

  factory AtomicSwap.fromJson(Map<String, dynamic> json) =>
      _$AtomicSwapFromJson(json);

  Map<String, dynamic> toJson() => _$AtomicSwapToJson(this);

  /// Create a copy of this atomic swap with updated fields
  AtomicSwap copyWith({
    int? id,
    int? listingId,
    String? buyer,
    String? seller,
    List<int>? secretHash,
    BigInt? amount,
    String? cryptoType,
    BigInt? timeout,
    AtomicSwapStatus? status,
    BigInt? createdAt,
  }) {
    return AtomicSwap(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      secretHash: secretHash ?? this.secretHash,
      amount: amount ?? this.amount,
      cryptoType: cryptoType ?? this.cryptoType,
      timeout: timeout ?? this.timeout,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AtomicSwap) return false;
    return id == other.id &&
        listingId == other.listingId &&
        buyer == other.buyer &&
        seller == other.seller &&
        secretHash.toString() == other.secretHash.toString() &&
        amount == other.amount &&
        cryptoType == other.cryptoType &&
        timeout == other.timeout &&
        status == other.status &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      listingId,
      buyer,
      seller,
      secretHash.toString(),
      amount,
      cryptoType,
      timeout,
      status,
      createdAt,
    );
  }

  /// Get the timeout timestamp for display
  DateTime get timeoutDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt.toInt() + timeout.toInt());

  /// Check if the swap has expired
  bool get isExpired => DateTime.now().isAfter(timeoutDateTime);

  /// Get the remaining time until timeout
  Duration get remainingTime {
    final now = DateTime.now();
    final timeoutDate = timeoutDateTime;
    return now.isAfter(timeoutDate)
        ? Duration.zero
        : timeoutDate.difference(now);
  }
}
