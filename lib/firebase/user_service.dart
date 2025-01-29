import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Create a new user
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
    String userId, {
    String? fullName,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _usersCollection.doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update address
  Future<void> updateAddress(String userId, AddressModel address) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        final addresses = user.addresses.map((addr) {
          return addr.id == address.id ? address : addr;
        }).toList();

        await _usersCollection.doc(userId).update({
          'addresses': addresses.map((addr) => addr.toMap()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  // Set default address
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        final addresses = user.addresses.map((addr) {
          return addr.id == addressId
              ? AddressModel(
                  id: addr.id,
                  street: addr.street,
                  city: addr.city,
                  state: addr.state,
                  country: addr.country,
                  postalCode: addr.postalCode,
                  label: addr.label,
                  number: addr.number,
                  isDefault: true,
            lat: addr.lat,
            long: addr.long,
                )
              : AddressModel(
                  id: addr.id,
                  street: addr.street,
                  city: addr.city,
                  state: addr.state,
                  country: addr.country,
                  postalCode: addr.postalCode,
                  label: addr.label,
                  number: addr.number,
                  isDefault: false,
            lat: addr.lat,
            long: addr.long,
                );
        }).toList();

        await _usersCollection.doc(userId).update({
          'addresses': addresses.map((addr) => addr.toMap()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  // Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }
      return null;
    });
  }

  // Read a single user
  Future<UserModel?> getUser(String id) async {
    try {
      final doc = await _usersCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update a user
  Future<void> updateUser(String id, UserModel user) async {
    try {
      await _usersCollection.doc(id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    try {
      await _usersCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Add address to user
  Future<void> addAddress(String userId, AddressModel address) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        final addresses = [...user.addresses, address];
        await _usersCollection.doc(userId).update({
          'addresses': addresses.map((addr) => addr.toMap()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  // Remove address from user
  Future<void> removeAddress(String userId, String addressId) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        final addresses =
            user.addresses.where((addr) => addr.id != addressId).toList();
        await _usersCollection.doc(userId).update({
          'addresses': addresses.map((addr) => addr.toMap()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to remove address: $e');
    }
  }
}
