import 'dart:async';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Supported wallet types
enum WalletType {
  metamask('MetaMask', 'metamask'),
  walletConnect('WalletConnect', 'walletconnect'),
  internetIdentity('Internet Identity', 'internet_identity');

  const WalletType(this.displayName, this.identifier);
  final String displayName;
  final String identifier;
}

/// Wallet connection status
enum WalletConnectionStatus { disconnected, connecting, connected, error }

/// Wallet account information
class WalletAccount {
  final String address;
  final String? name;
  final WalletType walletType;
  final Map<String, double> balances;

  const WalletAccount({
    required this.address,
    this.name,
    required this.walletType,
    this.balances = const {},
  });

  WalletAccount copyWith({
    String? address,
    String? name,
    WalletType? walletType,
    Map<String, double>? balances,
  }) {
    return WalletAccount(
      address: address ?? this.address,
      name: name ?? this.name,
      walletType: walletType ?? this.walletType,
      balances: balances ?? this.balances,
    );
  }
}

/// Multi-wallet service for blockchain interactions
class WalletService {
  final Logger _logger;
  final StreamController<WalletConnectionStatus> _statusController =
      StreamController<WalletConnectionStatus>.broadcast();
  final StreamController<WalletAccount?> _accountController =
      StreamController<WalletAccount?>.broadcast();

  WalletConnectionStatus _status = WalletConnectionStatus.disconnected;
  WalletAccount? _currentAccount;

  WalletService({required Logger logger}) : _logger = logger;

  /// Current wallet connection status
  WalletConnectionStatus get status => _status;

  /// Currently connected wallet account
  WalletAccount? get currentAccount => _currentAccount;

  /// Stream of connection status changes
  Stream<WalletConnectionStatus> get statusStream => _statusController.stream;

  /// Stream of account changes
  Stream<WalletAccount?> get accountStream => _accountController.stream;

  /// Check if a wallet type is available on current platform
  bool isWalletAvailable(WalletType walletType) {
    switch (walletType) {
      case WalletType.metamask:
        return kIsWeb; // MetaMask only available on web
      case WalletType.walletConnect:
        return true; // WalletConnect works on all platforms
      case WalletType.internetIdentity:
        return true; // Internet Identity works on all platforms
    }
  }

  /// Connect to a specific wallet type
  Future<bool> connect(WalletType walletType) async {
    if (!isWalletAvailable(walletType)) {
      _logger.logError(
        'Wallet ${walletType.displayName} not available on this platform',
      );
      return false;
    }

    _setStatus(WalletConnectionStatus.connecting);

    try {
      switch (walletType) {
        case WalletType.metamask:
          return await _connectMetaMask();
        case WalletType.walletConnect:
          return await _connectWalletConnect();
        case WalletType.internetIdentity:
          return await _connectInternetIdentity();
      }
    } catch (e) {
      _logger.logError('Failed to connect to ${walletType.displayName}: $e');
      _setStatus(WalletConnectionStatus.error);
      return false;
    }
  }

  /// Disconnect current wallet
  Future<void> disconnect() async {
    if (_currentAccount != null) {
      _logger.logInfo(
        'Disconnecting from ${_currentAccount!.walletType.displayName}',
      );
    }

    _currentAccount = null;
    _setStatus(WalletConnectionStatus.disconnected);
    _accountController.add(null);
  }

  /// Set connection status and notify listeners
  void _setStatus(WalletConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      _logger.logInfo('Wallet status changed to: ${newStatus.name}');
    }
  }

  // MetaMask implementation
  Future<bool> _connectMetaMask() async {
    if (!kIsWeb) return false;

    try {
      await Future.delayed(const Duration(seconds: 1));

      const mockAccount = WalletAccount(
        address: '0x1234567890123456789012345678901234567890',
        name: 'MetaMask Account 1',
        walletType: WalletType.metamask,
        balances: {'ETH': 1.5, 'BTC': 0.05},
      );

      _currentAccount = mockAccount;
      _setStatus(WalletConnectionStatus.connected);
      _accountController.add(_currentAccount);

      _logger.logInfo('Connected to MetaMask: ${mockAccount.address}');
      return true;
    } catch (e) {
      _logger.logError('MetaMask connection failed: $e');
      return false;
    }
  }

  // WalletConnect implementation
  Future<bool> _connectWalletConnect() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      const mockAccount = WalletAccount(
        address: '0x9876543210987654321098765432109876543210',
        name: 'Mobile Wallet',
        walletType: WalletType.walletConnect,
        balances: {'ETH': 0.8, 'USDC': 500.0},
      );

      _currentAccount = mockAccount;
      _setStatus(WalletConnectionStatus.connected);
      _accountController.add(_currentAccount);

      _logger.logInfo('Connected to WalletConnect: ${mockAccount.address}');
      return true;
    } catch (e) {
      _logger.logError('WalletConnect connection failed: $e');
      return false;
    }
  }

  // Internet Identity implementation
  Future<bool> _connectInternetIdentity() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      const mockAccount = WalletAccount(
        address: 'rrkah-fqaaa-aaaah-qcufa-cai',
        name: 'Internet Identity',
        walletType: WalletType.internetIdentity,
        balances: {'ICP': 10.5, 'ckBTC': 0.001},
      );

      _currentAccount = mockAccount;
      _setStatus(WalletConnectionStatus.connected);
      _accountController.add(_currentAccount);

      _logger.logInfo('Connected to Internet Identity: ${mockAccount.address}');
      return true;
    } catch (e) {
      _logger.logError('Internet Identity connection failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
    _accountController.close();
  }
}
