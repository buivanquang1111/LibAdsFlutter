import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:example/config/global_colors.dart';
import 'package:example/config/global_txt_style.dart';
import 'package:example/main.dart';
import 'package:example/screen/onboard/controller/onboard_controller.dart';
import 'package:example/screen/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardScreen1 extends StatefulWidget {
  const OnboardScreen1({super.key});

  @override
  State<StatefulWidget> createState() => OnBoardState1();
}

class OnBoardState1 extends State<OnboardScreen1> {
  final controller = Get.put(OnboardController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: Column(
          children: [
            SizedBox(height: 40.h),
            SizedBox(
              height: 435.h,
              child: PageView.builder(
                controller: controller.pgCtrl,
                itemCount: controller.lstOnboardImg.length,
                itemBuilder: (BuildContext context, int index) {
                  return controller.lstOnboardImg[index];
                },
                onPageChanged: (value) {
                  controller.onchange(value);
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  SizedBox(width: 10.w),
                  SmoothPageIndicator(
                    controller: controller.pgCtrl,
                    effect: ExpandingDotsEffect(
                      dotColor: GlobalColors.darkGray,
                      activeDotColor: GlobalColors.primary,
                      spacing: 8.w,
                      expansionFactor: 2.5.w,
                      dotWidth: 8.w,
                      dotHeight: 8.h,
                    ),
                    count: controller.lstOnboardImg.length,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => controller.onPress(),
                    child: Text(
                      controller.txt.value.tr,
                      style: GlobalTextStyles.font17w500.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: adIdManager.smallNativeAdHeight,
              child: introAdCtrl != null
                  ? EasyPreloadNativeAd(
                      controller: introAdCtrl!,
                      factoryId: adIdManager.nativeIntroFactory,
                      height: adIdManager.smallNativeAdHeight,
                      color: GlobalColors.lightGray,
                    )
                  : null,
            ),
          ],
        ),
      );
    });
  }
}
