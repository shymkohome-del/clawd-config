import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/market/cubit/listing_detail_cubit.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadListing();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadListing() {
    Logger.instance.logDebug(
      'Loading listing detail for ID: ${widget.listingId}',
      tag: 'ListingDetailScreen',
    );
    context.read<ListingDetailCubit>().loadListing(widget.listingId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.listingDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareListing(context),
            tooltip: l10n.shareListing,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'report', child: Text(l10n.reportListing)),
            ],
          ),
        ],
      ),
      body: BlocConsumer<ListingDetailCubit, ListingDetailState>(
        listener: (context, state) {
          if (state.status == ListingDetailStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? l10n.errorLoadingListing),
                action: SnackBarAction(
                  label: l10n.retry,
                  onPressed: _loadListing,
                ),
              ),
            );
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
    ListingDetailState state,
    AppLocalizations l10n,
  ) {
    switch (state.status) {
      case ListingDetailStatus.initial:
      case ListingDetailStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ListingDetailStatus.failure:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? l10n.errorLoadingListing,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadListing, child: Text(l10n.retry)),
            ],
          ),
        );

      case ListingDetailStatus.success:
        final listing = state.listing;
        if (listing == null) {
          return Center(
            child: Text(
              l10n.listingNotFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return _buildListingContent(context, listing, l10n);
    }
  }

  Widget _buildListingContent(
    BuildContext context,
    Listing listing,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(listing, l10n),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndPrice(listing, context),
                const SizedBox(height: 16),
                _buildDescription(listing, context, l10n),
                const SizedBox(height: 24),
                _buildSellerInfo(listing, context, l10n),
                const SizedBox(height: 24),
                _buildLocationInfo(listing, context, l10n),
                const SizedBox(height: 24),
                _buildCategoryInfo(listing, context, l10n),
                const SizedBox(height: 32),
                _buildActionButtons(context, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Listing listing, AppLocalizations l10n) {
    if (listing.images.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noImagesAvailable,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: listing.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              Logger.instance.logDebug(
                'Image gallery page changed to: $index',
                tag: 'ListingDetailScreen',
              );
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Center(
                    child: Image.network(
                      listing.images[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        Logger.instance.logWarn(
                          'Failed to load image: ${listing.images[index]}',
                          tag: 'ListingDetailScreen',
                          error: error,
                          stackTrace: stackTrace,
                        );
                        return Container(
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 64),
                              SizedBox(height: 8),
                              Text('Image not available'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${l10n.imageGallery} ${index + 1} ${l10n.imageOf} ${listing.images.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (listing.images.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                listing.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleAndPrice(Listing listing, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${listing.priceUSD.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (listing.cryptoType.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Accepts ${listing.cryptoType}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(
    Listing listing,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.descriptionLabel,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(listing.description, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildSellerInfo(
    Listing listing,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final state = context.watch<ListingDetailCubit>().state;
    final userProfile = state.sellerProfile;

    // Use real reputation data from user profile, fall back to mock data if not available
    final reputation = userProfile?.reputation ?? 0;
    final reputationColor = _getReputationColor(reputation);
    final reputationText = _getReputationText(reputation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sellerInfo,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _viewSellerProfile(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    userProfile?.displayName.isNotEmpty == true
                        ? userProfile!.displayName[0].toUpperCase()
                        : listing.seller.isNotEmpty
                        ? listing.seller[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userProfile?.displayName ?? listing.seller,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          if (userProfile?.kycVerified == true)
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.sellerReputation}: $reputation',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: reputationColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          if (reputation > 0)
                            Text(
                              '($reputationText)',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getReputationColor(int reputation) {
    if (reputation >= 1000) return Colors.green;
    if (reputation >= 500) return Colors.amber;
    if (reputation >= 100) return Colors.orange;
    return Colors.red;
  }

  String _getReputationText(int reputation) {
    if (reputation >= 1000) return 'Expert';
    if (reputation >= 500) return 'Trusted';
    if (reputation >= 100) return 'Established';
    if (reputation >= 50) return 'Newcomer';
    return 'Novice';
  }

  Widget _buildLocationInfo(
    Listing listing,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 20),
        const SizedBox(width: 8),
        Text(
          '${l10n.sellerLocation}: ${listing.location}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategoryInfo(
    Listing listing,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        const Icon(Icons.category, size: 20),
        const SizedBox(width: 8),
        Text(
          '${l10n.categoryLabel}: ${listing.category}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 16),
        Icon(
          listing.condition == ListingCondition.newCondition
              ? Icons.new_releases
              : listing.condition == ListingCondition.used
              ? Icons.history
              : Icons.settings_backup_restore,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          _getConditionText(listing.condition, l10n),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _buyNow(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.buyNow),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _contactSeller(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.contactSeller),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getConditionText(ListingCondition condition, AppLocalizations l10n) {
    switch (condition) {
      case ListingCondition.newCondition:
        return l10n.conditionNew;
      case ListingCondition.used:
        return l10n.conditionUsed;
      case ListingCondition.refurbished:
        return l10n.conditionRefurbished;
    }
  }

  void _shareListing(BuildContext context) {
    Logger.instance.logDebug(
      'Share listing clicked',
      tag: 'ListingDetailScreen',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'report':
        Logger.instance.logDebug(
          'Report listing clicked',
          tag: 'ListingDetailScreen',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report functionality coming soon')),
        );
        break;
    }
  }

  void _contactSeller(BuildContext context) {
    Logger.instance.logDebug(
      'Contact seller clicked',
      tag: 'ListingDetailScreen',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact seller functionality coming soon')),
    );
  }

  void _buyNow(BuildContext context) {
    Logger.instance.logDebug('Buy Now clicked', tag: 'ListingDetailScreen');

    final state = context.read<ListingDetailCubit>().state;
    if (state.listing != null) {
      // Navigate to swap initiation flow
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buy Now functionality - initiating swap...'),
        ),
      );
    }
  }

  void _viewSellerProfile(BuildContext context) {
    Logger.instance.logDebug(
      'View seller profile clicked',
      tag: 'ListingDetailScreen',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seller profile view coming soon')),
    );
  }
}
