import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/blockchain/price_oracle_service.dart';
import 'package:crypto_market/core/blockchain/atomic_swap_service.dart';
import 'package:crypto_market/core/services/notification_service.dart';
import 'package:crypto_market/features/market/providers/buy_flow_provider.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/widgets/price_conversion_widget.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

class BuyListingScreen extends StatefulWidget {
  const BuyListingScreen({super.key, required this.listing});

  final Listing listing;

  @override
  State<BuyListingScreen> createState() => _BuyListingScreenState();
}

class _BuyListingScreenState extends State<BuyListingScreen> {
  late BuyFlowProvider _buyFlowProvider;

  @override
  void initState() {
    super.initState();
    _initializeBuyFlow();
  }

  @override
  void dispose() {
    _buyFlowProvider.reset();
    super.dispose();
  }

  void _initializeBuyFlow() {
    Logger.instance.logDebug(
      'Initializing buy flow for listing: ${widget.listing.id}',
      tag: 'BuyListingScreen',
    );

    _buyFlowProvider = BuyFlowProvider(
      priceOracleService: PriceOracleService(),
      atomicSwapService: AtomicSwapService(),
      notificationService: NotificationService(),
    );

    _buyFlowProvider.initializeBuyFlow(widget.listing);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _buyFlowProvider,
      child: const BuyListingView(),
    );
  }
}

class BuyListingView extends StatelessWidget {
  const BuyListingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.buyFlowTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(context),
          tooltip: l10n.buyFlowCancelButton,
        ),
      ),
      body: BlocConsumer<BuyFlowProvider, BuyFlowState>(
        listener: (context, state) {
          if (state.hasError) {
            _showErrorDialog(context, state.errorMessage, l10n);
          } else if (state.isCompleted) {
            _showCompletionSuccess(context, l10n);
          }
        },
        builder: (context, state) {
          return _buildBody(context, state, l10n);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    if (state.status == BuyFlowStatus.loading && state.listing == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.listing == null) {
      return _buildErrorView(context, state.errorMessage, l10n);
    }

    return Column(
      children: [
        _buildProgressIndicator(context, state, l10n),
        Expanded(child: _buildStepContent(context, state, l10n)),
        _buildActionButtons(context, state, l10n),
      ],
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: BuyFlowStep.values.map((step) {
              final isActive = state.currentStep == step;
              final isCompleted =
                  state.progress >
                  BuyFlowStep.values.indexOf(step) / BuyFlowStep.values.length;

              return Expanded(
                child: Column(
                  children: [
                    _buildStepIndicator(
                      context,
                      step: step,
                      isActive: isActive,
                      isCompleted: isCompleted,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStepTitle(step, l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required BuyFlowStep step,
    required bool isActive,
    required bool isCompleted,
    required AppLocalizations l10n,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Theme.of(context).primaryColor
            : isActive
            ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
            : Colors.grey[300],
        border: Border.all(
          color: isActive ? Theme.of(context).primaryColor : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${BuyFlowStep.values.indexOf(step) + 1}',
                style: TextStyle(
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    switch (state.currentStep) {
      case BuyFlowStep.price:
        return _buildPriceStep(context, state, l10n);
      case BuyFlowStep.confirm:
        return _buildConfirmStep(context, state, l10n);
      case BuyFlowStep.payment:
        return _buildPaymentStep(context, state, l10n);
      case BuyFlowStep.completion:
        return _buildCompletionStep(context, state, l10n);
    }
  }

  Widget _buildPriceStep(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    if (state.status == BuyFlowStatus.loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state.priceConversion == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.buyFlowErrorMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<BuyFlowProvider>().refreshPriceConversion(),
              child: Text(l10n.buyFlowErrorRetry),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.buyFlowPriceTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.buyFlowPriceDescription,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          PriceConversionWidget(
            conversion: state.priceConversion!,
            onRefresh: () =>
                context.read<BuyFlowProvider>().refreshPriceConversion(),
            isLoading: state.status == BuyFlowStatus.loading,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.buyFlowConfirmTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.buyFlowConfirmDescription,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmRow(
                    context,
                    label: l10n.buyFlowConfirmListing,
                    value: state.listing?.title ?? '',
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildConfirmRow(
                    context,
                    label: l10n.buyFlowConfirmSeller,
                    value: state.listing?.seller ?? '',
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  if (state.priceConversion != null) ...[
                    _buildConfirmRow(
                      context,
                      label: l10n.buyFlowUsdAmount,
                      value:
                          '\$${(state.priceConversion!.cryptoAmount * state.priceConversion!.exchangeRate).toStringAsFixed(2)}',
                      l10n: l10n,
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmRow(
                      context,
                      label: l10n.buyFlowCryptoAmount,
                      value:
                          '${state.priceConversion!.cryptoAmount.toStringAsFixed(8)} ${state.priceConversion!.cryptoType}',
                      l10n: l10n,
                      isHighlighted: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(
    BuildContext context, {
    required String label,
    required String value,
    required AppLocalizations l10n,
    bool isHighlighted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Theme.of(context).primaryColor : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.buyFlowPaymentTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.buyFlowPaymentDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (state.status == BuyFlowStatus.loading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.buyFlowPaymentGenerating,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<BuyFlowProvider>().confirmPurchase(),
                icon: Icon(Icons.lock),
                label: Text(l10n.buyFlowConfirmButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStep(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  l10n.buyFlowCompleteTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.buyFlowCompleteSuccess,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (state.atomicSwap != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.buyFlowCompleteSwapCreated(state.atomicSwap!.id),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.buyFlowCompleteNextSteps,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepItem(
                    context,
                    number: '1',
                    text: state.listing?.seller != null
                        ? l10n.buyFlowCompleteStep1(state.listing!.seller)
                        : 'Contact seller to confirm payment details',
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    context,
                    number: '2',
                    text: l10n.buyFlowCompleteStep2,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    context,
                    number: '3',
                    text: l10n.buyFlowCompleteStep3,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required String number,
    required String text,
    required AppLocalizations l10n,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BuyFlowState state,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.canGoBack)
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<BuyFlowProvider>().previousStep(),
                  child: Text(l10n.buyFlowBackButton),
                ),
              ),
            if (state.canGoBack) const SizedBox(width: 12),
            Expanded(
              flex: state.canGoBack ? 2 : 1,
              child: ElevatedButton(
                onPressed: state.canProceed
                    ? () {
                        if (state.currentStep == BuyFlowStep.payment) {
                          context.read<BuyFlowProvider>().confirmPurchase();
                        } else {
                          context.read<BuyFlowProvider>().nextStep();
                        }
                      }
                    : null,
                child: Text(
                  state.currentStep == BuyFlowStep.payment
                      ? l10n.buyFlowConfirmButton
                      : l10n.buyFlowNextButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String? errorMessage,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.buyFlowErrorTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? l10n.buyFlowErrorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.buyFlowErrorCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<BuyFlowProvider>()
                        .refreshPriceConversion(),
                    child: Text(l10n.buyFlowErrorRetry),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(BuyFlowStep step, AppLocalizations l10n) {
    switch (step) {
      case BuyFlowStep.price:
        return l10n.buyFlowStepPrice;
      case BuyFlowStep.confirm:
        return l10n.buyFlowStepConfirm;
      case BuyFlowStep.payment:
        return l10n.buyFlowStepPayment;
      case BuyFlowStep.completion:
        return l10n.buyFlowStepCompletion;
    }
  }

  void _handleClose(BuildContext context) {
    final buyFlowProvider = context.read<BuyFlowProvider>();
    buyFlowProvider.reset();
    Navigator.of(context).pop();
  }

  void _showErrorDialog(
    BuildContext context,
    String? errorMessage,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.buyFlowErrorTitle),
        content: Text(errorMessage ?? l10n.buyFlowErrorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showCompletionSuccess(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.buyFlowCompleteSuccess),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
