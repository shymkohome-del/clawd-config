/// Represents the status of an atomic swap transaction
enum AtomicSwapStatus {
  /// Initial state when swap is created
  created,
  
  /// Seller has sent handshake (HTLC address shared)
  handshakeSent,
  
  /// Buyer has acknowledged handshake and is ready to pay
  handshakeAccepted,
  
  /// Buyer has paid into the HTLC (funds locked)
  paymentReceived,
  
  /// Buyer has revealed secret and claimed funds
  completed,
  
  /// Swap was cancelled before completion
  cancelled,
  
  /// Seller auto-cancelled due to payment window expiration
  sellerAutoCancelled,
  
  /// Refund processed (timeout or error)
  refunded,
}

/// Atomic swap model representing a P2P cryptocurrency exchange
class AtomicSwap {
  /// Unique identifier for the swap
  final String id;
  
  /// Seller's principal ID (ICP identity)
  final String sellerId;
  
  /// Buyer's principal ID
  final String buyerId;
  
  /// Cryptocurrency being sold (e.g., 'BTC', 'SOL', 'TRX')
  final String fromAsset;
  
  /// Cryptocurrency being bought
  final String toAsset;
  
  /// Amount seller will receive
  final double fromAmount;
  
  /// Amount buyer will pay
  final double toAmount;
  
  /// Current status of the swap
  final AtomicSwapStatus status;
  
  /// Payment blockchain (e.g., 'solana', 'tron', 'bitcoin')
  final String paymentBlockchain;
  
  /// Seller's payment address for the swap
  final String? sellerPaymentAddress;
  
  /// Buyer's payment address
  final String? buyerPaymentAddress;
  
  /// Transaction hash of seller's funding transaction
  final String? sellerFundingTxHash;
  
  /// Transaction hash of buyer's payment
  final String? buyerPaymentTxHash;
  
  /// HTLC address generated for this swap
  final String? htlcAddress;
  
  /// Secret hash (SHA-256 of the preimage)
  final String? secretHash;
  
  /// Preimage that reveals the secret (only buyer knows initially)
  final String? secretPreimage;
  
  /// HTLC timeout duration in seconds (default: 24 hours)
  final int htlcTimeoutSeconds;
  
  /// Whether this is a testnet transaction
  final bool isTestnet;
  
  /// Unix timestamp when swap was created
  final int createdAt;
  
  /// Unix timestamp of last status update
  final int updatedAt;
  
  /// Optional memo/note for the swap
  final String? memo;
  
  // === NEW FIELDS FOR SELLER AUTO-CANCEL ===
  
  /// Timestamp when handshake was accepted by buyer
  final DateTime? handshakeAcceptedAt;
  
  /// Time window buyer has to make payment after accepting handshake
  final Duration? paymentWindow;
  
  /// Whether seller has enabled auto-cancel for this swap
  final bool? sellerAutoCancelEnabled;
  
  // === COMPUTED PROPERTIES ===
  
  /// Check if payment window has expired
  bool get isPaymentWindowExpired {
    if (handshakeAcceptedAt == null) {
      return false;
    }
    final window = paymentWindow ?? const Duration(hours: 24);
    return DateTime.now().isAfter(handshakeAcceptedAt!.add(window));
  }
  
  /// Get remaining time until payment window expires
  Duration? get remainingPaymentTime {
    if (handshakeAcceptedAt == null) {
      return null;
    }
    final window = paymentWindow ?? const Duration(hours: 24);
    final expiry = handshakeAcceptedAt!.add(window);
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
  
  /// Check if swap is in a state where auto-cancel can apply
  bool get canAutoCancel {
    return status == AtomicSwapStatus.handshakeAccepted &&
           sellerAutoCancelEnabled == true &&
           isPaymentWindowExpired;
  }
  
  // === CONSTRUCTORS ===
  
  const AtomicSwap({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.fromAsset,
    required this.toAsset,
    required this.fromAmount,
    required this.toAmount,
    required this.status,
    required this.paymentBlockchain,
    this.sellerPaymentAddress,
    this.buyerPaymentAddress,
    this.sellerFundingTxHash,
    this.buyerPaymentTxHash,
    this.htlcAddress,
    this.secretHash,
    this.secretPreimage,
    this.htlcTimeoutSeconds = 86400,
    this.isTestnet = true,
    required this.createdAt,
    required this.updatedAt,
    this.memo,
    // New optional fields
    this.handshakeAcceptedAt,
    this.paymentWindow,
    this.sellerAutoCancelEnabled,
  });
  
  // === FACTORY CONSTRUCTORS ===
  
  /// Create a new swap in created state
  factory AtomicSwap.created({
    required String id,
    required String sellerId,
    required String buyerId,
    required String fromAsset,
    required String toAsset,
    required double fromAmount,
    required double toAmount,
    required String paymentBlockchain,
    bool isTestnet = true,
    String? memo,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return AtomicSwap(
      id: id,
      sellerId: sellerId,
      buyerId: buyerId,
      fromAsset: fromAsset,
      toAsset: toAsset,
      fromAmount: fromAmount,
      toAmount: toAmount,
      status: AtomicSwapStatus.created,
      paymentBlockchain: paymentBlockchain,
      isTestnet: isTestnet,
      memo: memo,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // === COPY WITH ===
  
  AtomicSwap copyWith({
    String? id,
    String? sellerId,
    String? buyerId,
    String? fromAsset,
    String? toAsset,
    double? fromAmount,
    double? toAmount,
    AtomicSwapStatus? status,
    String? paymentBlockchain,
    String? sellerPaymentAddress,
    String? buyerPaymentAddress,
    String? sellerFundingTxHash,
    String? buyerPaymentTxHash,
    String? htlcAddress,
    String? secretHash,
    String? secretPreimage,
    int? htlcTimeoutSeconds,
    bool? isTestnet,
    int? createdAt,
    int? updatedAt,
    String? memo,
    DateTime? handshakeAcceptedAt,
    Duration? paymentWindow,
    bool? sellerAutoCancelEnabled,
  }) {
    return AtomicSwap(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      fromAsset: fromAsset ?? this.fromAsset,
      toAsset: toAsset ?? this.toAsset,
      fromAmount: fromAmount ?? this.fromAmount,
      toAmount: toAmount ?? this.toAmount,
      status: status ?? this.status,
      paymentBlockchain: paymentBlockchain ?? this.paymentBlockchain,
      sellerPaymentAddress: sellerPaymentAddress ?? this.sellerPaymentAddress,
      buyerPaymentAddress: buyerPaymentAddress ?? this.buyerPaymentAddress,
      sellerFundingTxHash: sellerFundingTxHash ?? this.sellerFundingTxHash,
      buyerPaymentTxHash: buyerPaymentTxHash ?? this.buyerPaymentTxHash,
      htlcAddress: htlcAddress ?? this.htlcAddress,
      secretHash: secretHash ?? this.secretHash,
      secretPreimage: secretPreimage ?? this.secretPreimage,
      htlcTimeoutSeconds: htlcTimeoutSeconds ?? this.htlcTimeoutSeconds,
      isTestnet: isTestnet ?? this.isTestnet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memo: memo ?? this.memo,
      handshakeAcceptedAt: handshakeAcceptedAt ?? this.handshakeAcceptedAt,
      paymentWindow: paymentWindow ?? this.paymentWindow,
      sellerAutoCancelEnabled: sellerAutoCancelEnabled ?? this.sellerAutoCancelEnabled,
    );
  }
  
  /// Update status with timestamp
  AtomicSwap withStatus(AtomicSwapStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  /// Mark handshake as accepted with timestamp
  AtomicSwap acceptHandshake() {
    return copyWith(
      status: AtomicSwapStatus.handshakeAccepted,
      handshakeAcceptedAt: DateTime.now(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  // === JSON SERIALIZATION ===
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'fromAsset': fromAsset,
      'toAsset': toAsset,
      'fromAmount': fromAmount,
      'toAmount': toAmount,
      'status': status.name,
      'paymentBlockchain': paymentBlockchain,
      'sellerPaymentAddress': sellerPaymentAddress,
      'buyerPaymentAddress': buyerPaymentAddress,
      'sellerFundingTxHash': sellerFundingTxHash,
      'buyerPaymentTxHash': buyerPaymentTxHash,
      'htlcAddress': htlcAddress,
      'secretHash': secretHash,
      'secretPreimage': secretPreimage,
      'htlcTimeoutSeconds': htlcTimeoutSeconds,
      'isTestnet': isTestnet,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'memo': memo,
      'handshakeAcceptedAt': handshakeAcceptedAt?.toIso8601String(),
      'paymentWindowSeconds': paymentWindow?.inSeconds,
      'sellerAutoCancelEnabled': sellerAutoCancelEnabled,
    };
  }
  
  factory AtomicSwap.fromJson(Map<String, dynamic> json) {
    return AtomicSwap(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      buyerId: json['buyerId'] as String,
      fromAsset: json['fromAsset'] as String,
      toAsset: json['toAsset'] as String,
      fromAmount: (json['fromAmount'] as num).toDouble(),
      toAmount: (json['toAmount'] as num).toDouble(),
      status: AtomicSwapStatus.values.byName(json['status'] as String),
      paymentBlockchain: json['paymentBlockchain'] as String,
      sellerPaymentAddress: json['sellerPaymentAddress'] as String?,
      buyerPaymentAddress: json['buyerPaymentAddress'] as String?,
      sellerFundingTxHash: json['sellerFundingTxHash'] as String?,
      buyerPaymentTxHash: json['buyerPaymentTxHash'] as String?,
      htlcAddress: json['htlcAddress'] as String?,
      secretHash: json['secretHash'] as String?,
      secretPreimage: json['secretPreimage'] as String?,
      htlcTimeoutSeconds: json['htlcTimeoutSeconds'] as int? ?? 86400,
      isTestnet: json['isTestnet'] as bool? ?? true,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      memo: json['memo'] as String?,
      handshakeAcceptedAt: json['handshakeAcceptedAt'] != null
          ? DateTime.parse(json['handshakeAcceptedAt'] as String)
          : null,
      paymentWindow: json['paymentWindowSeconds'] != null
          ? Duration(seconds: json['paymentWindowSeconds'] as int)
          : null,
      sellerAutoCancelEnabled: json['sellerAutoCancelEnabled'] as bool?,
    );
  }
  
  // === EQUATABLE ===
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AtomicSwap && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'AtomicSwap(id: $id, status: ${status.name}, '
           'from: $fromAsset $fromAmount → to: $toAsset $toAmount)';
  }
}
