import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/trading/models/swap_contract.dart';
import 'package:crypto_market/features/trading/providers/htlc_provider.dart';
import 'package:crypto_market/features/trading/services/htlc_service.dart';
import 'package:crypto_market/shared/widgets/basic_widgets.dart';

class InitiateSwapScreen extends StatefulWidget {
  final Listing listing;

  const InitiateSwapScreen({super.key, required this.listing});

  @override
  State<InitiateSwapScreen> createState() => _InitiateSwapScreenState();
}

class _InitiateSwapScreenState extends State<InitiateSwapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _lockTimeHoursController = TextEditingController();

  CryptoType _selectedCryptoType = CryptoType.btc;
  int _selectedLockTimeHours = 24;
  bool _showConfirmation = false;
  bool _isCalculating = false;
  BigInt? _calculatedCryptoAmount;
  BigInt? _currentPriceInUsd;

  @override
  void initState() {
    super.initState();
    _lockTimeHoursController.text = _selectedLockTimeHours.toString();
    _loadCurrentPrice();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _lockTimeHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return AppScaffold(
        title: l10n.initiateSwap,
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return AppScaffold(
      title: l10n.initiateSwap,
      body: BlocConsumer<HTLCProvider, HTLCState>(
        listener: (context, state) {
          if (state is HTLCInitiationSuccess) {
            _showSuccessDialog(context, state.response, l10n);
          } else if (state is HTLCError) {
            _showErrorDialog(context, state.error, l10n);
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is HTLCLoading || _isCalculating,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, l10n),
                    SizedBox(height: 24.h),
                    _buildListingInfo(context, l10n),
                    SizedBox(height: 24.h),
                    _buildSwapParameters(context, l10n),
                    SizedBox(height: 24.h),
                    _buildPriceInfo(context, l10n),
                    SizedBox(height: 24.h),
                    _buildSecurityInfo(context, l10n),
                    SizedBox(height: 32.h),
                    _buildActionButtons(context, l10n),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.initiateSwap,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.initiateSwapDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildListingInfo(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.listingDetails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listing.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$${widget.listing.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                if (widget.listing.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      widget.listing.images.first,
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80.w,
                          height: 80.h,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapParameters(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.swapParameters,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: l10n.usdAmount,
            hintText: l10n.usdAmountHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            prefixIcon: const Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.amountRequired;
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return l10n.amountMustBePositive;
            }
            return null;
          },
          onChanged: (value) {
            _calculateCryptoAmount();
          },
        ),
        SizedBox(height: 16.h),
        DropdownButtonFormField<CryptoType>(
          value: _selectedCryptoType,
          decoration: InputDecoration(
            labelText: l10n.cryptoType,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            prefixIcon: const Icon(Icons.currency_bitcoin),
          ),
          items: CryptoType.values.map((type) {
            return DropdownMenuItem<CryptoType>(
              value: type,
              child: Text(_getCryptoTypeLabel(type, l10n)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCryptoType = value;
              });
              _calculateCryptoAmount();
            }
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _lockTimeHoursController,
          decoration: InputDecoration(
            labelText: l10n.lockTimeHours,
            hintText: l10n.lockTimeHoursHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            prefixIcon: const Icon(Icons.timer),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.lockTimeRequired;
            }
            final hours = int.tryParse(value);
            if (hours == null || hours < 1 || hours > 168) {
              return l10n.lockTimeRangeError;
            }
            return null;
          },
          onChanged: (value) {
            final hours = int.tryParse(value);
            if (hours != null && hours >= 1 && hours <= 168) {
              setState(() {
                _selectedLockTimeHours = hours;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriceInfo(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.priceInformation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12.h),
            if (_currentPriceInUsd != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getCryptoTypeLabel(_selectedCryptoType, l10n)} ${l10n.price}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${(_currentPriceInUsd! / BigInt.from(1000000)).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
            if (_calculatedCryptoAmount != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.youWillReceive,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${_formatCryptoAmount(_calculatedCryptoAmount!)} ${_getCryptoTypeLabel(_selectedCryptoType, l10n)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (_currentPriceInUsd == null || _calculatedCryptoAmount == null)
              Text(
                l10n.enterAmountToCalculate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  l10n.htlcSecurity,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.htlcSecurityDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.htlcSecurityNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canInitiateSwap() ? _showInitiateConfirmation : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(l10n.initiateSwap),
          ),
        ),
        SizedBox(height: 12.h),
        OutlinedButton(
          onPressed: () => context.pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  bool _canInitiateSwap() {
    return _formKey.currentState?.validate() == true &&
        _calculatedCryptoAmount != null &&
        _currentPriceInUsd != null;
  }

  void _calculateCryptoAmount() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    setState(() {
      _isCalculating = true;
      _calculatedCryptoAmount = null;
    });

    try {
      final htlcService = HTLCService(
        atomicSwapService: context.read(),
        icpService: context.read(),
        priceOracleService: context.read(),
        logger: Logger.instance,
      );

      final result = await htlcService.calculateCryptoAmount(
        usdAmount: BigInt.from(amount * 100), // Convert to cents
        cryptoType: _selectedCryptoType,
      );

      if (mounted) {
        setState(() {
          _isCalculating = false;
        });

        result.fold(
          (cryptoAmount) {
            setState(() {
              _calculatedCryptoAmount = cryptoAmount;
            });
          },
          (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.failedToCalculateAmount),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToCalculateAmount),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _loadCurrentPrice() async {
    try {
      final htlcService = HTLCService(
        atomicSwapService: context.read(),
        icpService: context.read(),
        priceOracleService: context.read(),
        logger: Logger.instance,
      );

      final result = await htlcService.getCryptoPriceInUsd(_selectedCryptoType);

      if (mounted) {
        result.fold(
          (price) {
            setState(() {
              _currentPriceInUsd = price;
            });
          },
          (error) {
            // Silently handle price loading errors
          },
        );
      }
    } catch (error) {
      // Silently handle price loading errors
    }
  }

  void _showInitiateConfirmation() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmInitiateSwap),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmInitiateSwapDescription),
            SizedBox(height: 16.h),
            _buildConfirmationDetails(l10n),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _initiateSwap();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDetails(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n.listing, widget.listing.title),
            SizedBox(height: 8.h),
            _buildDetailRow(l10n.usdAmount, '\$${_amountController.text}'),
            SizedBox(height: 8.h),
            _buildDetailRow(
              l10n.cryptoType,
              _getCryptoTypeLabel(_selectedCryptoType, l10n),
            ),
            SizedBox(height: 8.h),
            if (_calculatedCryptoAmount != null)
              _buildDetailRow(
                l10n.cryptoAmount,
                '${_formatCryptoAmount(_calculatedCryptoAmount!)} ${_getCryptoTypeLabel(_selectedCryptoType, l10n)}',
              ),
            SizedBox(height: 8.h),
            _buildDetailRow(
              l10n.lockTimeHours,
              '$_selectedLockTimeHours ${l10n.hours}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:', style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _initiateSwap() {
    if (!_canInitiateSwap()) return;

    final amount = double.parse(_amountController.text);
    final usdAmount = BigInt.from(amount * 100); // Convert to cents

    context.read<HTLCProvider>().add(
      InitiateSwapRequested(
        listingId: widget.listing.id.toString(),
        cryptoAsset: _selectedCryptoType,
        amount: _calculatedCryptoAmount!,
        priceInUsd: usdAmount,
        lockTimeHours: _selectedLockTimeHours,
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    InitiateSwapResponse response,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12.w),
            Text(l10n.swapInitiatedSuccess),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.swapInitiatedSuccessDescription),
            SizedBox(height: 16.h),
            _buildSwapSuccessDetails(response, l10n),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Theme.of(context).colorScheme.error,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.important,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.secretWarning,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.pop(); // Return to previous screen
            },
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapSuccessDetails(
    InitiateSwapResponse response,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n.swapId, response.contract.id),
            SizedBox(height: 8.h),
            _buildDetailRow(
              l10n.cryptoAmount,
              '${_formatCryptoAmount(response.contract.amount)} ${_getCryptoTypeLabel(response.contract.cryptoAsset, l10n)}',
            ),
            SizedBox(height: 8.h),
            _buildDetailRow(
              l10n.status,
              _getStatusLabel(response.contract.status, l10n),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    DomainError error,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            SizedBox(width: 12.w),
            Text(l10n.error),
          ],
        ),
        content: Text(_getErrorMessage(error, l10n)),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(l10n.ok)),
        ],
      ),
    );
  }

  String _getCryptoTypeLabel(CryptoType type, AppLocalizations l10n) {
    switch (type) {
      case CryptoType.btc:
        return 'BTC';
      case CryptoType.eth:
        return 'ETH';
      case CryptoType.icp:
        return 'ICP';
      case CryptoType.usdt:
        return 'USDT';
      case CryptoType.usdc:
        return 'USDC';
    }
  }

  String _formatCryptoAmount(BigInt amount) {
    // Format based on crypto type
    if (amount > BigInt.from(1000000)) {
      return (amount / BigInt.from(1000000)).toStringAsFixed(6);
    } else {
      return amount.toString();
    }
  }

  String _getStatusLabel(SwapContractStatus status, AppLocalizations l10n) {
    switch (status) {
      case SwapContractStatus.initiated:
        return l10n.initiated;
      case SwapContractStatus.locked:
        return l10n.locked;
      case SwapContractStatus.completed:
        return l10n.completed;
      case SwapContractStatus.refunded:
        return l10n.refunded;
      case SwapContractStatus.expired:
        return l10n.expired;
    }
  }

  String _getErrorMessage(DomainError error, AppLocalizations l10n) {
    switch (error.type) {
      case DomainErrorType.network:
        return l10n.networkError;
      case DomainErrorType.validation:
        return l10n.validationError;
      case DomainErrorType.business:
        return l10n.businessError;
      default:
        return l10n.unknownError;
    }
  }
}
