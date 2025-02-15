import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:Super96Store/models/user_model.dart';
import 'package:Super96Store/screens/auth/login_screen.dart';

// Add a ProfileController using GetX for state management
class ProfileController extends GetxController {
  final user = Rxn<UserModel>();
  final isLoading = false.obs;

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to update user profile
      await Future.delayed(const Duration(seconds: 1));
      user.value = updatedUser;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
