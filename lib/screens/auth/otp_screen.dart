import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocerry/notifier/auth_provider.dart';
import 'package:grocerry/screens/auth/home_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.message_rounded,
                  size: 70,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 40),
                Text(
                  'Verification Code',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the 6-digit code sent to your phone',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (_) {},
                    onCompleted: (otp) async {
                      final auth = context.read<AuthProviderC>();
                      if (await auth.verifyOTP(otp, context)) {
                        Get.off(() => HomeScreen());
                      }
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 50,
                      fieldWidth: 45,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey[300],
                      selectedColor: Theme.of(context).primaryColor,
                    ),
                    enableActiveFill: true,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.scale,
                    animationDuration: const Duration(milliseconds: 200),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}