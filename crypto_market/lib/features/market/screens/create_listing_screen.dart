import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/market/cubit/create_listing_cubit.dart';
import 'package:crypto_market/features/market/models/create_listing_request.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/shared/utils/validators.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

/// Screen for creating a new marketplace listing
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _shippingOptionController = TextEditingController();

  String _selectedCryptoType = 'BTC';
  ListingCondition _selectedCondition = ListingCondition.used;
  String _selectedCategory = 'Electronics';
  final List<String> _shippingOptions = [];
  final List<File> _selectedImages = [];
  bool _isUploadingImages = false;

  final List<String> _cryptoTypes = ['BTC', 'ETH', 'ICP', 'USDC', 'USDT'];
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Automotive',
    'Collectibles',
    'Other',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _shippingOptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createListingTitle), elevation: 0),
      body: BlocConsumer<CreateListingCubit, CreateListingState>(
        listener: (context, state) {
          if (state is CreateListingSuccess) {
            Logger.instance.logInfo(
              'Listing created with ID: ${state.listingId}',
              tag: 'CreateListingScreen',
            );
            _showSuccessAndNavigateBack(context, l10n);
          } else if (state is CreateListingFailure) {
            Logger.instance.logError(
              'Failed to create listing: ${state.error}',
              tag: 'CreateListingScreen',
            );
            _showErrorDialog(context, l10n, state.error);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CreateListingSubmitting;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitleField(l10n),
                    const SizedBox(height: 16),
                    _buildDescriptionField(l10n),
                    const SizedBox(height: 16),
                    _buildPriceField(l10n),
                    const SizedBox(height: 16),
                    _buildCryptoTypeDropdown(l10n),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(l10n),
                    const SizedBox(height: 16),
                    _buildConditionDropdown(l10n),
                    const SizedBox(height: 16),
                    _buildLocationField(l10n),
                    const SizedBox(height: 16),
                    _buildShippingOptionsSection(l10n),
                    const SizedBox(height: 16),
                    _buildImagesSection(l10n),
                    const SizedBox(height: 32),
                    _buildSubmitButton(l10n, isSubmitting),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleField(AppLocalizations l10n) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: l10n.listingTitleLabel,
        hintText: l10n.titleHint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final result = StringValidator.validateLength(
          value,
          l10n.listingTitleLabel,
          minLength: 3,
          maxLength: 100,
        );
        return result.isValid ? null : result.firstError;
      },
      maxLength: 100,
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n.descriptionLabel,
        hintText: l10n.descriptionHint,
        border: const OutlineInputBorder(),
      ),
      maxLines: 4,
      validator: (value) {
        final result = StringValidator.validateLength(
          value,
          l10n.descriptionLabel,
          minLength: 10,
          maxLength: 1000,
        );
        return result.isValid ? null : result.firstError;
      },
      maxLength: 1000,
    );
  }

  Widget _buildPriceField(AppLocalizations l10n) {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: l10n.priceLabel,
        hintText: '100',
        border: const OutlineInputBorder(),
        prefixText: '\$',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        final result = NumericValidator.validateInteger(
          value,
          l10n.priceLabel,
          min: 1,
          max: 1000000,
        );

        if (result.isValid) {
          return null;
        }

        final error = result.firstError;
        if (error == null) {
          return null;
        }

        if (error.contains('required')) {
          return l10n.priceRequired;
        }
        if (error.contains('at least') || error.contains('positive')) {
          return l10n.pricePositive;
        }

        return error;
      },
    );
  }

  Widget _buildCryptoTypeDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      key: const ValueKey('create_listing_crypto_dropdown'),
      initialValue: _selectedCryptoType,
      decoration: InputDecoration(
        labelText: l10n.cryptoTypeLabel,
        border: const OutlineInputBorder(),
      ),
      items: _cryptoTypes.map((crypto) {
        return DropdownMenuItem(value: crypto, child: Text(crypto));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCryptoType = value!;
        });
      },
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      key: const ValueKey('create_listing_category_dropdown'),
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: l10n.categoryLabel,
        border: const OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(_categoryLabel(category, l10n)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildConditionDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<ListingCondition>(
      key: const ValueKey('create_listing_condition_dropdown'),
      initialValue: _selectedCondition,
      decoration: InputDecoration(
        labelText: l10n.conditionLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: ListingCondition.newCondition,
          child: Text(l10n.conditionNew),
        ),
        DropdownMenuItem(
          value: ListingCondition.used,
          child: Text(l10n.conditionUsed),
        ),
        DropdownMenuItem(
          value: ListingCondition.refurbished,
          child: Text(l10n.conditionRefurbished),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCondition = value!;
        });
      },
    );
  }

  String _categoryLabel(String category, AppLocalizations l10n) {
    final normalized = category
        .toLowerCase()
        .replaceAll('&', '')
        .replaceAll(' ', '_');
    switch (normalized) {
      case 'electronics':
        return l10n.categoryElectronics;
      case 'fashion':
        return l10n.categoryFashion;
      case 'home__garden':
      case 'home_garden':
        return l10n.categoryHomeGarden;
      case 'sports':
        return l10n.categorySports;
      case 'books':
        return l10n.categoryBooks;
      case 'automotive':
        return l10n.categoryAutomotive;
      case 'collectibles':
        return l10n.categoryCollectibles;
      case 'other':
        return l10n.categoryOther;
      default:
        return category;
    }
  }

  Widget _buildLocationField(AppLocalizations l10n) {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: l10n.locationLabel,
        hintText: l10n.locationHint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final result = StringValidator.validateLength(
          value,
          l10n.locationLabel,
          minLength: 2,
          maxLength: 100,
        );
        return result.isValid ? null : result.firstError;
      },
    );
  }

  Widget _buildShippingOptionsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.shippingOptionsLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_shippingOptions.isNotEmpty)
          ...(_shippingOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Card(
              child: ListTile(
                title: Text(option),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _shippingOptions.removeAt(index);
                    });
                  },
                ),
              ),
            );
          })),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _shippingOptionController,
                decoration: InputDecoration(
                  hintText: l10n.addShippingOption,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addShippingOption,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (_shippingOptions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n.shippingOptionsRequired,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.imagesLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                final image = _selectedImages[index];
                return Card(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isUploadingImages ? null : _pickImages,
          icon: Icon(
            _isUploadingImages ? Icons.upload : Icons.add_photo_alternate,
          ),
          label: Text(
            _isUploadingImages ? l10n.uploadingImages : l10n.addImages,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n, bool isSubmitting) {
    return ElevatedButton(
      key: const ValueKey('create_listing_submit_button'),
      onPressed: isSubmitting ? null : _submitForm,
      child: isSubmitting
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(l10n.creating),
              ],
            )
          : Text(l10n.createListing),
    );
  }

  void _addShippingOption() {
    final option = _shippingOptionController.text.trim();
    if (option.isNotEmpty && !_shippingOptions.contains(option)) {
      setState(() {
        _shippingOptions.add(option);
        _shippingOptionController.clear();
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      setState(() {
        _isUploadingImages = true;
      });

      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        final files = pickedFiles.map((file) => File(file.path)).toList();
        setState(() {
          _selectedImages.addAll(files);
        });

        Logger.instance.logDebug(
          'Selected ${pickedFiles.length} images',
          tag: 'CreateListingScreen',
        );
      }
    } catch (error) {
      Logger.instance.logError(
        'Error picking images',
        tag: 'CreateListingScreen',
        error: error,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.imageUploadFailed)));
      }
    } finally {
      setState(() {
        _isUploadingImages = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_shippingOptions.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shippingOptionsRequired)));
      return;
    }

    final priceInUSD = int.tryParse(_priceController.text);
    if (priceInUSD == null || priceInUSD <= 0) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.priceRequired)));
      return;
    }

    // For now, use placeholder IPFS hashes until IPFS service is implemented
    // In the future, this should upload images to IPFS and get hashes
    final imageHashes = _selectedImages.isNotEmpty
        ? _selectedImages
              .asMap()
              .entries
              .map((entry) => 'placeholder_hash_${entry.key}')
              .toList()
        : <String>[];

    final request = CreateListingRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priceUSD: priceInUSD,
      cryptoType: _selectedCryptoType,
      images: imageHashes,
      category: _selectedCategory,
      condition: _selectedCondition,
      location: _locationController.text.trim(),
      shippingOptions: List.from(_shippingOptions),
    );

    Logger.instance.logDebug(
      'Submitting listing creation request: ${request.title}',
      tag: 'CreateListingScreen',
    );

    context.read<CreateListingCubit>().createListing(request);
  }

  void _showSuccessAndNavigateBack(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.listingCreatedSuccess),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back after a short delay
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        navigator.pop();
      }
    });
  }

  void _showErrorDialog(
    BuildContext context,
    AppLocalizations l10n,
    String error,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.errorTitleOperation),
        content: Text('${l10n.listingCreatedFailure}: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
