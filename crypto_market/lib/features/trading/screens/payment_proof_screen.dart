import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';
import 'package:crypto_market/shared/widgets/basic_widgets.dart';

class PaymentProofScreen extends StatefulWidget {
  final String swapId;
  final String paymentMethodId;

  const PaymentProofScreen({
    super.key,
    required this.swapId,
    required this.paymentMethodId,
  });

  @override
  State<PaymentProofScreen> createState() => _PaymentProofScreenState();
}

class _PaymentProofScreenState extends State<PaymentProofScreen> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  final _notesController = TextEditingController();

  File? _selectedImage;
  PaymentProofType _selectedProofType = PaymentProofType.receipt;
  bool _isUploading = false;

  @override
  void dispose() {
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return AppScaffold(
        title: l10n.paymentProof,
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return AppScaffold(
      title: l10n.paymentProof,
      body: LoadingOverlay(
        isLoading: _isUploading,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, l10n),
                SizedBox(height: 24.h),
                _buildProofTypeSelector(context, l10n),
                SizedBox(height: 24.h),
                _buildProofUploadSection(context, l10n),
                SizedBox(height: 24.h),
                _buildTransactionDetails(context, l10n),
                SizedBox(height: 32.h),
                _buildSubmitButton(context, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.submitPaymentProof,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.paymentProofDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.paymentProofSecurityNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProofTypeSelector(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectProofType,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: PaymentProofType.values.map((type) {
            final isSelected = _selectedProofType == type;
            return _buildProofTypeChip(context, type, isSelected, l10n);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProofTypeChip(
    BuildContext context,
    PaymentProofType type,
    bool isSelected,
    AppLocalizations l10n,
  ) {
    return ChoiceChip(
      label: Text(_getProofTypeLabel(type, l10n)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedProofType = type;
        });
      },
      avatar: Icon(_getProofTypeIcon(type), size: 20.w),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildProofUploadSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.uploadProof, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 12.h),
        if (_selectedImage != null)
          _buildImagePreview(context)
        else
          _buildImageUploadArea(context, l10n),
      ],
    );
  }

  Widget _buildImageUploadArea(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2.w,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48.w,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.uploadReceiptOrPhoto,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.uploadInstructions,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.camera),
              ),
              SizedBox(width: 12.w),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(AppLocalizations.of(context).retake),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text(AppLocalizations.of(context).chooseAnother),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionDetails(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transactionDetails,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 12.h),
        if (_selectedProofType == PaymentProofType.transactionId) ...[
          TextFormField(
            controller: _transactionIdController,
            decoration: InputDecoration(
              labelText: l10n.transactionId,
              hintText: l10n.transactionIdHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (_selectedProofType == PaymentProofType.transactionId &&
                  (value == null || value.isEmpty)) {
                return l10n.transactionIdRequired;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
        ],
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: l10n.additionalNotes,
            hintText: l10n.additionalNotesHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedImage != null ? _submitPaymentProof : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: Text(l10n.submitProof),
      ),
    );
  }

  IconData _getProofTypeIcon(PaymentProofType type) {
    switch (type) {
      case PaymentProofType.receipt:
        return Icons.receipt;
      case PaymentProofType.transactionId:
        return Icons.confirmation_number;
      case PaymentProofType.photo:
        return Icons.photo_camera;
      case PaymentProofType.confirmation:
        return Icons.verified;
    }
  }

  String _getProofTypeLabel(PaymentProofType type, AppLocalizations l10n) {
    switch (type) {
      case PaymentProofType.receipt:
        return l10n.receipt;
      case PaymentProofType.transactionId:
        return l10n.transactionId;
      case PaymentProofType.photo:
        return l10n.photo;
      case PaymentProofType.confirmation:
        return l10n.confirmation;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to pick image',
        tag: 'PaymentProofScreen',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).imagePickerError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submitPaymentProof() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseUploadImage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final l10n = AppLocalizations.of(context);
      final authState = context.read<AuthCubit>().state as AuthSuccess;

      // Simulate IPFS upload
      final ipfsHash = await _uploadToIPFS(_selectedImage!);

      // Create payment proof
      final paymentProof = PaymentProof(
        id: PaymentEncryptionService.generatePaymentProofId(widget.swapId),
        swapId: widget.swapId,
        paymentMethodId: widget.paymentMethodId,
        proofType: _selectedProofType,
        ipfsHash: ipfsHash,
        submittedBy: authState.user.id,
        submittedAt: DateTime.now(),
      );

      // Submit to backend (simulated)
      await _submitPaymentProofToBackend(paymentProof);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentProofSubmitted),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to submit payment proof',
        tag: 'PaymentProofScreen',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).paymentProofSubmitError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String> _uploadToIPFS(File image) async {
    // Simulate IPFS upload
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock IPFS hash
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco$timestamp';
  }

  Future<void> _submitPaymentProofToBackend(PaymentProof paymentProof) async {
    // Simulate backend submission
    await Future.delayed(const Duration(seconds: 1));

    Logger.instance.logDebug(
      'Payment proof submitted: ${paymentProof.id}',
      tag: 'PaymentProofScreen',
    );
  }
}
