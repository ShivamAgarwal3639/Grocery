import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Super96Store/models/user_model.dart';
import 'package:Super96Store/notifier/address_provider.dart';
import 'package:Super96Store/notifier/auth_provider.dart';
import 'package:Super96Store/screens/profile/edit_address_page.dart';
import 'package:provider/provider.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  void initState() {
    super.initState();
    // Load addresses once when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.phoneNumber != null) {
        context.read<AddressProvider>().loadAddresses(authProvider.phoneNumber!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Addresses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () => Get.to(() => const AddEditAddressPage()),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, _) {
        if (addressProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
          );
        }

        if (addressProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    addressProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);

                    if (authProvider.phoneNumber != null) addressProvider.loadAddresses(authProvider.phoneNumber!);
                  },
                  child: const Text('Retry', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          );
        }

        if (addressProvider.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('No addresses yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () => Get.to(() => const AddEditAddressPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(160, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add Address'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: addressProvider.addresses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildAddressCard(
              context,
              addressProvider.addresses[index]
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Get.to(() => AddEditAddressPage(address: address)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getAddressIcon(address.label),
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address.label ?? 'Address',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                    itemBuilder: (context) => [
                      if (!address.isDefault)
                        PopupMenuItem(
                          value: 'default',
                          child: const Text('Set as Default', style: TextStyle(fontSize: 14)),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red, fontSize: 14)),
                      ),
                    ],
                    onSelected: (value) async {
                      if (authProvider.phoneNumber == null) return;
                      switch (value) {
                        case 'delete':
                          _showDeleteDialog(context, authProvider.phoneNumber!, address.id);
                          break;
                        case 'default':
                          await addressProvider.setDefaultAddress(authProvider.phoneNumber!, address.id);
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                address.street,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${address.city}, ${address.state} ${address.postalCode}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(String? label) {
    switch (label?.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  void _showDeleteDialog(BuildContext context, String userId, String addressId) {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Delete Address?'),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await addressProvider.deleteAddress(userId, addressId);
              Get.snackbar(
                'Success',
                'Address deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                margin: const EdgeInsets.all(12),
                borderRadius: 8,
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}