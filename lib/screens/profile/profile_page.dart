import 'package:Super96Store/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:Super96Store/firebase/storage/user_profile.dart';
import 'package:Super96Store/firebase/user_service.dart';
import 'package:Super96Store/models/user_model.dart';
import 'package:Super96Store/notifier/auth_provider.dart';
import 'package:Super96Store/screens/auth/login_screen.dart';
import 'package:Super96Store/screens/order_list_page.dart';
import 'package:Super96Store/screens/profile/address_screen.dart';
import 'package:Super96Store/screens/profile/edit_profile_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final authProvider = Provider.of<AuthProvider>(Get.context!, listen: false);

  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  Future<void> _handleImageUpload() async {
    try {
      setState(() => _isUploading = true);
      // Show option dialog
      final choice = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Choose Image Source'),
          content: const Text('Where would you like to pick an image from?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Camera'),
            ),
          ],
        ),
      );

      if (choice == null) return;

      // Pick image
      final imageFile = await _storageService.pickImage(fromCamera: choice);
      if (imageFile == null) return;

      // Show upload progress dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Uploading image...'),
            ],
          ),
        ),
      );

      // Upload image
      await _storageService.uploadProfileImage(
          authProvider.phoneNumber!, imageFile);

      // Close progress dialog
      if (!mounted) return;
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Profile image updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update profile image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserModel?>(
        stream: _userService.streamUser(authProvider.phoneNumber!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'User not found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    _buildProfileOptions(user),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      // expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: user.profileImage != null
                        ? CachedNetworkImage(
                            imageUrl: user.profileImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person, size: 60),
                          )
                        : const Icon(Icons.person,
                            size: 60, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 20,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.camera_alt,
                                size: 20, color: Colors.white),
                            onPressed: _handleImageUpload,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user.fullName ?? 'No Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.phoneNumber ?? "No Phone Number",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Update your profile details',
            onTap: () => Get.to(() => EditProfilePage(user: user)),
          ),
          _buildOptionTile(
            icon: Icons.location_on_outlined,
            title: 'My Addresses',
            subtitle: 'Manage delivery addresses',
            onTap: () => Get.to(() => const AddressListPage()),
          ),
          _buildOptionTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Order History',
            subtitle: 'View your past orders',
            onTap: () => Get.to(() => OrderListPage()),
          ),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with your orders',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.exit_to_app,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: textColor?.withOpacity(0.1) ??
                Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: textColor ?? Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: textColor ?? Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                Utility.logout(authProvider.phoneNumber);
                await authProvider.signOut();
                Get.offAll(() => LoginScreen());
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
