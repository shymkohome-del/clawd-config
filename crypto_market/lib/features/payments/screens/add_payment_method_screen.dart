import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';
import 'package:crypto_market/features/payments/providers/payment_method_provider.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  final PaymentMethod? paymentMethod;

  const AddPaymentMethodScreen({super.key, this.paymentMethod});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  PaymentMethodType _selectedType = PaymentMethodType.bankTransfer;
  final _formKey = GlobalKey<FormState>();

  // Bank transfer fields
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _swiftCodeController = TextEditingController();
  final _ibanController = TextEditingController();

  // Digital wallet fields
  final _walletIdController = TextEditingController();
  final _providerController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  // Cash payment fields
  final _meetingLocationController = TextEditingController();
  final _preferredTimeController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod != null) {
      _populateFormFromPaymentMethod(widget.paymentMethod!);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _accountHolderNameController.dispose();
    _bankNameController.dispose();
    _swiftCodeController.dispose();
    _ibanController.dispose();
    _walletIdController.dispose();
    _providerController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _accountNameController.dispose();
    _meetingLocationController.dispose();
    _preferredTimeController.dispose();
    _contactInfoController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  void _populateFormFromPaymentMethod(PaymentMethod paymentMethod) {
    setState(() {
      _selectedType = paymentMethod.type;
    });

    // In a real implementation, you would decrypt the details here
    // For now, we'll populate with placeholder data
    switch (paymentMethod.type) {
      case PaymentMethodType.bankTransfer:
        _accountNumberController.text = '••••••••';
        _routingNumberController.text = '•••••••••';
        _accountHolderNameController.text = 'Account Holder';
        _bankNameController.text = 'Bank Name';
        break;
      case PaymentMethodType.digitalWallet:
        _walletIdController.text = '••••••••';
        _providerController.text = 'Provider';
        break;
      case PaymentMethodType.cash:
        _meetingLocationController.text = 'Meeting Location';
        _preferredTimeController.text = 'Preferred Time';
        _contactInfoController.text = 'Contact Info';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addPaymentMethod)),
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.paymentMethod == null
              ? l10n.addPaymentMethod
              : l10n.editPaymentMethod,
        ),
      ),
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

          if (state.status == PaymentMethodStatus.loaded && !state.isLoading) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPaymentTypeSelector(context, l10n),
                      SizedBox(height: 24.h),
                      _buildPaymentForm(context, state, l10n),
                      SizedBox(height: 32.h),
                      _buildActionButtons(context, l10n, authState.user.id),
                    ],
                  ),
                ),
              ),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentTypeSelector(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectPaymentType,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildPaymentTypeCard(
                context,
                PaymentMethodType.bankTransfer,
                Icons.account_balance,
                l10n.bankTransfer,
                l10n.bankTransferDescription,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildPaymentTypeCard(
                context,
                PaymentMethodType.digitalWallet,
                Icons.account_balance_wallet,
                l10n.digitalWallet,
                l10n.digitalWalletDescription,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildPaymentTypeCard(
                context,
                PaymentMethodType.cash,
                Icons.money,
                l10n.cash,
                l10n.cashDescription,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentTypeCard(
    BuildContext context,
    PaymentMethodType type,
    IconData icon,
    String title,
    String description,
  ) {
    final isSelected = _selectedType == type;
    final color = isSelected ? Theme.of(context).colorScheme.primary : null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Card(
        color: isSelected ? color?.withValues(alpha: 0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: color ?? Colors.transparent, width: 2.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32.w,
                color:
                    color ??
                    Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(
    BuildContext context,
    PaymentMethodState state,
    AppLocalizations l10n,
  ) {
    switch (_selectedType) {
      case PaymentMethodType.bankTransfer:
        return _buildBankTransferForm(context, l10n);
      case PaymentMethodType.digitalWallet:
        return _buildDigitalWalletForm(context, l10n);
      case PaymentMethodType.cash:
        return _buildCashPaymentForm(context, l10n);
    }
  }

  Widget _buildBankTransferForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _accountNumberController,
          label: l10n.accountNumber,
          hint: l10n.accountNumberHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.accountNumberRequired;
            }
            return null;
          },
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _routingNumberController,
          label: l10n.routingNumber,
          hint: l10n.routingNumberHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.routingNumberRequired;
            }
            return null;
          },
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _accountHolderNameController,
          label: l10n.accountHolderName,
          hint: l10n.accountHolderNameHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.accountHolderNameRequired;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _bankNameController,
          label: l10n.bankName,
          hint: l10n.bankNameHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.bankNameRequired;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _swiftCodeController,
          label: l10n.swiftCode,
          hint: l10n.swiftCodeHint,
          isOptional: true,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _ibanController,
          label: l10n.iban,
          hint: l10n.ibanHint,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildDigitalWalletForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _walletIdController,
          label: l10n.walletId,
          hint: l10n.walletIdHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.walletIdRequired;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _providerController,
          label: l10n.provider,
          hint: l10n.providerHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.providerRequired;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _emailController,
          label: l10n.email,
          hint: l10n.emailHint,
          isOptional: true,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _phoneNumberController,
          label: l10n.phoneNumber,
          hint: l10n.phoneNumberHint,
          isOptional: true,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _accountNameController,
          label: l10n.accountName,
          hint: l10n.accountNameHint,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildCashPaymentForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _meetingLocationController,
          label: l10n.meetingLocation,
          hint: l10n.meetingLocationHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.meetingLocationRequired;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _preferredTimeController,
          label: l10n.preferredTime,
          hint: l10n.preferredTimeHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.preferredTimeRequired;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _contactInfoController,
          label: l10n.contactInfo,
          hint: l10n.contactInfoHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.contactInfoRequired;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _specialInstructionsController,
          label: l10n.specialInstructions,
          hint: l10n.specialInstructionsHint,
          isOptional: true,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool isOptional = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            if (isOptional) ...[
              SizedBox(width: 4.w),
              Text(
                '(${AppLocalizations.of(context).optional})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    String userId,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _savePaymentMethod(context, userId),
            child: Text(widget.paymentMethod == null ? l10n.add : l10n.save),
          ),
        ),
      ],
    );
  }

  void _savePaymentMethod(BuildContext context, String userId) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate payment method details
    context.read<PaymentMethodBloc>().add(
      ValidatePaymentMethod(
        type: _selectedType,
        accountNumber: _accountNumberController.text,
        routingNumber: _routingNumberController.text,
        accountHolderName: _accountHolderNameController.text,
        bankName: _bankNameController.text,
        swiftCode: _swiftCodeController.text,
        iban: _ibanController.text,
        walletId: _walletIdController.text,
        provider: _providerController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        accountName: _accountNameController.text,
        meetingLocation: _meetingLocationController.text,
        preferredTime: _preferredTimeController.text,
        contactInfo: _contactInfoController.text,
        specialInstructions: _specialInstructionsController.text,
        locale: Localizations.localeOf(context).languageCode,
      ),
    );

    // Add the payment method
    if (widget.paymentMethod == null) {
      context.read<PaymentMethodBloc>().add(
        AddPaymentMethod(
          userId: userId,
          type: _selectedType,
          accountNumber: _accountNumberController.text,
          routingNumber: _routingNumberController.text,
          accountHolderName: _accountHolderNameController.text,
          bankName: _bankNameController.text,
          swiftCode: _swiftCodeController.text,
          iban: _ibanController.text,
          walletId: _walletIdController.text,
          provider: _providerController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          accountName: _accountNameController.text,
          meetingLocation: _meetingLocationController.text,
          preferredTime: _preferredTimeController.text,
          contactInfo: _contactInfoController.text,
          specialInstructions: _specialInstructionsController.text,
          locale: Localizations.localeOf(context).languageCode,
        ),
      );
    } else {
      context.read<PaymentMethodBloc>().add(
        UpdatePaymentMethod(
          paymentMethodId: widget.paymentMethod!.id,
          type: _selectedType,
          accountNumber: _accountNumberController.text,
          routingNumber: _routingNumberController.text,
          accountHolderName: _accountHolderNameController.text,
          bankName: _bankNameController.text,
          swiftCode: _swiftCodeController.text,
          iban: _ibanController.text,
          walletId: _walletIdController.text,
          provider: _providerController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          accountName: _accountNameController.text,
          meetingLocation: _meetingLocationController.text,
          preferredTime: _preferredTimeController.text,
          contactInfo: _contactInfoController.text,
          specialInstructions: _specialInstructionsController.text,
          locale: Localizations.localeOf(context).languageCode,
        ),
      );
    }
  }
}
