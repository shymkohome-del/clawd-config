import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/features/market/models/price_conversion.dart';

/// Widget for displaying price conversion information with staleness warnings
class PriceConversionWidget extends StatelessWidget {
  final PriceConversionResponse conversion;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const PriceConversionWidget({
    super.key,
    required this.conversion,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isStale = conversion.isStale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.buyFlowPriceTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    onPressed: isLoading ? null : onRefresh,
                    icon: Icon(
                      Icons.refresh,
                      color: isLoading
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    tooltip: l10n.buyFlowRefreshButton,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.buyFlowPriceDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildPriceDisplay(context, l10n),
            const SizedBox(height: 12),
            _buildExchangeRateInfo(context, l10n),
            const SizedBox(height: 12),
            if (isStale) _buildStaleWarning(context, l10n),
            const SizedBox(height: 8),
            _buildTimestamp(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.buyFlowUsdAmount,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${conversion.cryptoAmount * conversion.exchangeRate}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.buyFlowCryptoAmount,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '${conversion.cryptoAmount.toStringAsFixed(8)} ${conversion.cryptoType}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeRateInfo(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(Icons.currency_exchange, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '${l10n.buyFlowExchangeRate}: 1 ${conversion.cryptoType} = \$${conversion.exchangeRate.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildStaleWarning(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.buyFlowPriceStaleWarning,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, AppLocalizations l10n) {
    final timestamp = conversion.timestampDateTime;
    final formattedTime = DateFormat('MMM dd, yyyy HH:mm:ss').format(timestamp);
    final age = Duration(milliseconds: conversion.ageMs);

    String ageText;
    if (age.inSeconds < 60) {
      ageText = '${age.inSeconds} seconds ago';
    } else if (age.inMinutes < 60) {
      ageText = '${age.inMinutes} minutes ago';
    } else if (age.inHours < 24) {
      ageText = '${age.inHours} hours ago';
    } else {
      ageText = '${age.inDays} days ago';
    }

    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '${l10n.buyFlowLastUpdated}: $formattedTime ($ageText)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
