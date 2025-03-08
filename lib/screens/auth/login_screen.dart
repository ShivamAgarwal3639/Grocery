import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Super96Store/notifier/auth_provider.dart';
import 'package:Super96Store/screens/auth/otp_screen.dart';
import 'package:provider/provider.dart';

// Define theme colors
const themeAccentColor = Color(0xFF4CAF50); // Green theme for delivery app
const mutedForegroundColor = Color(0xffD4D4D4);

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildHeader(context),
          Flexible(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Heading text
                  Text(
                    'Customer Login',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),

                  // Section separator
                  _buildSectionSeparator('Log in with your phone number'),

                  // Phone number field and button
                  _buildPhoneNumberFieldView(context),
                  const SizedBox(height: 128),

                  // Footer
                  _buildFooterView(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      height: MediaQuery.of(context).size.height * .45,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CAF50), // Primary green
            Color(0xFF2E7D32), // Darker green
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_rounded,
            size: 75,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Super96Store',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to access your account and start shopping.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mutedForegroundColor,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberFieldView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: mutedForegroundColor,
                  blurRadius: 2,
                  offset: Offset.zero,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Enter your phone number",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
                if (cleanNumber.length != 10) {
                  return 'Phone number must be exactly 10 digits';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => GestureDetector(
              onTap: auth.isLoading
                  ? null
                  : () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final success =
                    await auth.sendOTP(_phoneController.text);
                    if (success) {
                      // Store the BuildContext in a local variable
                      final scaffoldContext = context;

                      // Navigate to OTP screen
                      final result = await Get.to(() =>
                          OTPScreen(phoneNumber: _phoneController.text));

                      // If navigation was cancelled or failed, show error message
                      if (result == null && scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext)
                            .showSnackBar(
                          const SnackBar(
                            content: Text('Failed to verify OTP'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Failed to send OTP. Please try again later.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: auth.isLoading
                      ? themeAccentColor.withOpacity(0.7)
                      : themeAccentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: auth.isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSeparator(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: .5,
              color: mutedForegroundColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: .5,
              color: mutedForegroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('By continuing you agree to our'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            {
              "label": "Terms of Service",
              "onClick": () => print("Tapped Terms of Service!")
            },
            {
              "label": "Privacy Policy",
              "onClick": () => print("Tapped Privacy Policy!")
            },
          ]
              .map(
                (item) => Container(
              margin: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: item["onClick"] as VoidCallback,
                child: Text(
                  item["label"] as String,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                ),
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}