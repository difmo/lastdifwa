import 'dart:ui';

import 'package:difwa/config/app_color.dart';
import 'package:difwa/config/app_styles.dart';
import 'package:difwa/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 350,
                  child: SvgPicture.asset(
                    'assets/images/otp.svg', // Ensure this path is correct
                    semanticsLabel: 'Illustration',
                    // Optionally add color or placeholder
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'OTP Code Verification',
                  style: AppStyle.heading24Black,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'We have sent an OTP code to your Phone No\n+12 *** **88. Enter the OTP code below to verify.',
                  textAlign: TextAlign.center,
                  style: AppStyle.greyText16,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      List.generate(6, (index) => _buildOTPBox(context, index)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Resend OTP logic
                  },
                  child: Text(
                    "Didn't receive Code? Resend OTP",
                    style: AppStyle.heading2Black,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        )
                      : Text("Verify OTP", style: AppStyle.headingWhite),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOTP() async {
    setState(() {
      isLoading = true;
    });

    String otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        "Invalid OTP",
        "Please enter a valid 6-digit OTP code.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await Get.find<AuthController>().verifyOTP(otp);

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildOTPBox(BuildContext context, int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary),
      ),
      child: Center(
        child: TextField(
          controller: otpControllers[index],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
          maxLength: 1,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
          onChanged: (value) {
            if (value.length == 1 && index < 5) {
              FocusScope.of(context).nextFocus();
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).previousFocus();
            }
          },
        ),
      ),
    );
  }
}
