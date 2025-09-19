import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/payments/providers/payment_method_provider.dart';
import 'package:crypto_market/features/payments/screens/add_payment_method_screen.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';
import 'package:crypto_market/shared/widgets/basic_widgets.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<PaymentMethodBloc>().add(
        LoadPaymentMethods(userId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return AppScaffold(
        title: l10n.paymentMethods,
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return AppScaffold(
      title: l10n.paymentMethods,
      body: BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isLoading,
            child: Column(
              children: [
                _buildHeader(context, l10n),
                Expanded(child: _buildPaymentMethodsList(context, state, l10n)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPaymentMethod(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.managePaymentMethods,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.paymentMethodsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList(
    BuildContext context,
    PaymentMethodState state,
    AppLocalizations l10n,
  ) {
    if (state.status == PaymentMethodStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasPaymentMethods) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 64.w,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.noPaymentMethods,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.addPaymentMethodPrompt,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => _navigateToAddPaymentMethod(context),
              child: Text(l10n.addPaymentMethod),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadPaymentMethods();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: state.paymentMethods.length,
        itemBuilder: (context, index) {
          final paymentMethod = state.paymentMethods[index];
          return _buildPaymentMethodCard(context, paymentMethod, state, l10n);
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    PaymentMethod paymentMethod,
    PaymentMethodState state,
    AppLocalizations l10n,
  ) {
    final isSelected = state.selectedPaymentMethodId == paymentMethod.id;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          context.read<PaymentMethodBloc>().add(
            SelectPaymentMethod(paymentMethodId: paymentMethod.id),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getPaymentMethodIcon(paymentMethod.type),
                              size: 20.w,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                paymentMethod.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _getPaymentMethodTypeLabel(paymentMethod.type, l10n),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24.w,
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildVerificationBadge(
                    paymentMethod.verificationStatus,
                    l10n,
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(paymentMethod.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              if (paymentMethod.lastUsed != null) ...[
                SizedBox(height: 4.h),
                Text(
                  '${l10n.lastUsed}: ${_formatDate(paymentMethod.lastUsed!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _navigateToEditPaymentMethod(context, paymentMethod),
                      child: Text(l10n.edit),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _showDeleteConfirmation(context, paymentMethod),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: Text(l10n.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(
    VerificationStatus status,
    AppLocalizations l10n,
  ) {
    Color color;
    String text;

    switch (status) {
      case VerificationStatus.verified:
        color = Colors.green;
        text = l10n.verified;
        break;
      case VerificationStatus.pending:
        color = Colors.orange;
        text = l10n.pending;
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        text = l10n.rejected;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
      case PaymentMethodType.digitalWallet:
        return Icons.account_balance_wallet;
      case PaymentMethodType.cash:
        return Icons.money;
    }
  }

  String _getPaymentMethodTypeLabel(
    PaymentMethodType type,
    AppLocalizations l10n,
  ) {
    switch (type) {
      case PaymentMethodType.bankTransfer:
        return l10n.bankTransfer;
      case PaymentMethodType.digitalWallet:
        return l10n.digitalWallet;
      case PaymentMethodType.cash:
        return l10n.cash;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _navigateToAddPaymentMethod(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
    ).then((_) {
      _loadPaymentMethods();
    });
  }

  void _navigateToEditPaymentMethod(
    BuildContext context,
    PaymentMethod paymentMethod,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddPaymentMethodScreen(paymentMethod: paymentMethod),
      ),
    ).then((_) {
      _loadPaymentMethods();
    });
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PaymentMethod paymentMethod,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePaymentMethod),
        content: Text(l10n.deletePaymentMethodConfirmation),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<PaymentMethodBloc>().add(
                DeletePaymentMethod(paymentMethodId: paymentMethod.id),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
