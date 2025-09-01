import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/auth/cubit/profile_cubit.dart';
import 'package:crypto_market/features/auth/models/user_profile.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final String principal;

  const ProfileScreen({super.key, required this.principal});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Load profile data when screen initializes
    context.read<ProfileCubit>().loadProfile(widget.principal);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context).errorImagePicker);
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context).errorImagePicker);
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).selectImageSource),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context).gallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.of(context).camera),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileCubit>().updateProfile(
      principal: widget.principal,
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      profileImage: _selectedImage,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _errorToMessage(AuthError error) {
    final localizations = AppLocalizations.of(context);
    switch (error) {
      case AuthError.invalidCredentials:
        return localizations.errorInvalidCredentials;
      case AuthError.network:
        return localizations.errorNetwork;
      case AuthError.oauthDenied:
        return localizations.errorOAuthDenied;
      case AuthError.unknown:
        return localizations.errorUnknown;
    }
  }

  Widget _buildProfileImage(UserProfile profile) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!)
              : (profile.profileImage?.isNotEmpty == true
                    ? CachedNetworkImageProvider(
                        'https://ipfs.io/ipfs/${profile.profileImage}',
                      )
                    : null),
          child:
              _selectedImage == null && profile.profileImage?.isEmpty != false
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReputationBadge(UserProfile profile) {
    final trustLevel = profile.trustLevel;
    final theme = Theme.of(context);

    Color badgeColor;
    IconData badgeIcon;

    switch (trustLevel) {
      case TrustLevel.expert:
        badgeColor = Colors.purple;
        badgeIcon = Icons.stars;
        break;
      case TrustLevel.trusted:
        badgeColor = Colors.green;
        badgeIcon = Icons.verified;
        break;
      case TrustLevel.established:
        badgeColor = Colors.blue;
        badgeIcon = Icons.trending_up;
        break;
      case TrustLevel.newcomer:
        badgeColor = Colors.orange;
        badgeIcon = Icons.new_releases;
        break;
      case TrustLevel.novice:
        badgeColor = Colors.grey;
        badgeIcon = Icons.person_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            trustLevel.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${profile.reputation}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(UserProfile profile) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            enabled: _isEditing,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).username,
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.trim().isEmpty == true) {
                return null; // Username is optional
              }
              if (value!.trim().length < 3) {
                return AppLocalizations.of(context).usernameMinLength;
              }
              if (value.trim().length > 30) {
                return AppLocalizations.of(context).usernameMaxLength;
              }
              // Basic username validation
              final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
              if (!regex.hasMatch(value.trim())) {
                return AppLocalizations.of(context).usernameInvalidChars;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email field (read-only)
          TextFormField(
            initialValue: profile.email,
            enabled: false,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).email,
              prefixIcon: const Icon(Icons.email),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Auth provider field (read-only)
          TextFormField(
            initialValue: profile.authProvider,
            enabled: false,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).authProvider,
              prefixIcon: const Icon(Icons.security),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded || state is ProfileUpdating) {
                return IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: state is ProfileUpdating
                      ? null
                      : () {
                          if (_isEditing) {
                            _saveProfile();
                          } else {
                            // Initialize form with current values when starting edit
                            if (state is ProfileLoaded) {
                              _usernameController.text = state.profile.username;
                            }
                            _toggleEditMode();
                          }
                        },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            _showError(_errorToMessage(state.error));
          } else if (state is ProfileUpdateSuccess) {
            _showSuccess(AppLocalizations.of(context).profileUpdatedSuccess);
            setState(() {
              _isEditing = false;
              _selectedImage = null;
            });
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorToMessage(state.error),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileCubit>().loadProfile(
                          widget.principal,
                        );
                      },
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded ||
                state is ProfileUpdating ||
                state is ProfileUpdateSuccess) {
              UserProfile profile;
              bool isUpdating = false;

              if (state is ProfileLoaded) {
                profile = state.profile;
              } else if (state is ProfileUpdating) {
                profile = state.profile;
                isUpdating = true;
              } else {
                profile = (state as ProfileUpdateSuccess).profile;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Image
                    _buildProfileImage(profile),
                    const SizedBox(height: 24),

                    // Reputation Badge
                    _buildReputationBadge(profile),
                    const SizedBox(height: 24),

                    // Profile Form
                    _buildProfileForm(profile),

                    if (isUpdating) ...[
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).updatingProfile,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              );
            }

            // Initial state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
