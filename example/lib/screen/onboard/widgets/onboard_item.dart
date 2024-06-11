import 'package:example/config/global_txt_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OnboardImg extends StatelessWidget {
  final String path;
  final String title;
  final String content;
  const OnboardImg(
      {super.key,
      required this.path,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 65.h),
        Image.asset(
          path,
          height: 180.h,
          width: 292.w,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 82.h),
        Text(
          title.tr,
          textAlign: TextAlign.center,
          style: GlobalTextStyles.font22w600.copyWith(
            color: Colors.black,
          ),
        ),
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 37.5.w),
          child: Text(
            content.tr,
            textAlign: TextAlign.center,
            style: GlobalTextStyles.font15w400.copyWith(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
