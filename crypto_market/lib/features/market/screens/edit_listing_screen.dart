import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/core/logger/logger.dart';

class EditListingScreen extends StatefulWidget {
  const EditListingScreen({
    super.key,
    required this.listingId,
    required this.initialTitle,
    required this.initialPrice,
    this.initialImageUrl,
  });

  final String listingId;
  final String initialTitle;
  final int initialPrice;
  final String? initialImageUrl;

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _priceController =
        TextEditingController(text: widget.initialPrice.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.titleRequired;
    }
    return null;
  }

  String? _validatePrice(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.priceRequired;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return l10n.pricePositive;
    }
    return null;
  }

  Future<void> _pickImage() async {
    if (kDebugMode) {
      logger.logDebug('Image replacement initiated', tag: 'EditListing');
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
        if (kDebugMode) {
          logger.logDebug('Selected new image: ${picked.path}',
              tag: 'EditListing');
        }
        // Placeholder for IPFS upload
      }
    } catch (e, st) {
      if (kDebugMode) {
        logger.logDebug('Image pick error: $e',
            tag: 'EditListing', error: e, stackTrace: st);
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorImagePicker)));
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_formKey.currentState?.validate() != true) {
      if (kDebugMode) {
        logger.logDebug('Validation failed', tag: 'EditListing');
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmUpdateTitle),
        content: Text(l10n.confirmUpdateMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.confirmUpdateNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmUpdateYes),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;

    if (kDebugMode) {
      logger.logDebug('Updating listing ${widget.listingId}',
          tag: 'EditListing');
    }

    try {
      final market = context.read<MarketServiceProvider>();
      await market.updateListing(
        listingId: widget.listingId,
        title: _titleController.text.trim(),
        priceInUsd: int.parse(_priceController.text.trim()),
        imagePath: _selectedImage?.path,
      );
      if (!mounted) return;
      if (kDebugMode) {
        logger.logDebug('Update successful', tag: 'EditListing');
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.editSuccess)));
      Navigator.of(context).pop();
    } catch (e, st) {
      if (kDebugMode) {
        logger.logDebug('Update failed: $e',
            tag: 'EditListing', error: e, stackTrace: st);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.editFailure)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editListingTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('editTitleField'),
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.listingTitleLabel),
              validator: (v) => _validateTitle(v, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('editPriceField'),
              controller: _priceController,
              decoration: InputDecoration(labelText: l10n.priceLabel),
              keyboardType: TextInputType.number,
              validator: (v) => _validatePrice(v, l10n),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 200)
            else if (widget.initialImageUrl != null &&
                widget.initialImageUrl!.isNotEmpty)
              Image.network(widget.initialImageUrl!, height: 200),
            TextButton(
              onPressed: _pickImage,
              child: Text(l10n.replaceImage),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }
}

