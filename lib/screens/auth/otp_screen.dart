import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Super96Store/notifier/auth_provider.dart';
import 'package:Super96Store/screens/auth/home_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

// Define theme colors to match login_screen.dart
const themeAccentColor = Color(0xffF04F5F);
const mutedForegroundColor = Color(0xffD4D4D4);

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  int _remainingTime = 60; // Updated to 60 seconds to match the API timeout
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _remainingTime = 60;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _resendOTP() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.sendOTP(widget.phoneNumber);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _startTimer();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Heading text
                Text(
                  'Verification',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Enter the verification code sent to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.phoneNumber,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                // Section separator
                _buildSectionSeparator('Enter 6-digit verification code'),

                // OTP field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) => PinCodeTextField(
                      appContext: context,
                      length: 4,
                      onChanged: (_) {},
                      enabled: !auth.isLoading,
                      onCompleted: (otp) async {
                        final success =
                            await auth.verifyOTP(otp, widget.phoneNumber);
                        if (success) {
                          Get.offAll(() => HomeScreen());
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid verification code'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                        activeColor: themeAccentColor,
                        inactiveColor: mutedForegroundColor,
                        selectedColor: themeAccentColor,
                      ),
                      enableActiveFill: true,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.scale,
                      animationDuration: const Duration(milliseconds: 200),
                      boxShadows: [
                        BoxShadow(
                          color: mutedForegroundColor,
                          blurRadius: 2,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Resend code button/text
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => Center(
                    child: auth.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  themeAccentColor),
                            ),
                          )
                        : _canResend
                            ? GestureDetector(
                                onTap: _resendOTP,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: themeAccentColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 24),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Resend Code",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                'Resend code in $_remainingTime seconds',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 32),
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      height: MediaQuery.of(context).size.height *
          .30, // Slightly shorter than login screen
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CAF50), // Primary green
            Color(0xFF2E7D32),
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
            'Verify your identity to access your account',
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
}
