import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F6FF),
      child: SafeArea(
        child: Center(
          child: CustomText(
            text: 'Profile',
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
