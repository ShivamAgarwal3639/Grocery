import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:Super96Store/firebase/user_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery or camera
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70, // Compress image quality
        maxWidth: 1024, // Max width
        maxHeight: 1024, // Max height
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Upload image with progress
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Generate unique file name
      String fileName = 'profile_$userId${path.extension(imageFile.path)}';
      String storagePath = 'users/$userId/profile/$fileName';

      // Create storage reference
      final storageRef = _storage.ref().child(storagePath);

      // Create upload task
      UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/${path.extension(imageFile.path).replaceAll('.', '')}',
          customMetadata: {'userId': userId},
        ),
      );

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // You can use a stream controller to broadcast progress
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for upload to complete and get download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile in Firestore
      await _userService.updateUserProfile(
        userId,
        profileImage: downloadUrl,
      );

      // Delete old profile image if exists
      await _deleteOldProfileImage(userId);

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Delete old profile image
  Future<void> _deleteOldProfileImage(String userId) async {
    try {
      final result = await _storage.ref().child('users/$userId/profile').listAll();

      // Delete all files except the most recent one
      if (result.items.length > 1) {
        for (var item in result.items.sublist(0, result.items.length - 1)) {
          await item.delete();
        }
      }
    } catch (e) {
      print('Error deleting old profile images: $e');
      // Don't throw here as this is a cleanup operation
    }
  }

  // Delete all user images
  Future<void> deleteUserImages(String userId) async {
    try {
      final result = await _storage.ref().child('users/$userId').listAll();

      for (var prefix in result.prefixes) {
        final items = await prefix.listAll();
        for (var item in items.items) {
          await item.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete user images: $e');
    }
  }
}