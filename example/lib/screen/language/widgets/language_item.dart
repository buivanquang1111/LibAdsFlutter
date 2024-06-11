part of '../language.dart';

class LanguageItem extends GetWidget<LanguageController> {
  final LanguageModel data;
  const LanguageItem(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: controller.currentLanguage.value == data.code
                  ? GlobalColors.lightBlue
                  : GlobalColors.lightGray,
              borderRadius: BorderRadius.all(
                Radius.circular(12.w),
              ),
              border: Border.all(
                width: 1.5,
                color: controller.currentLanguage.value == data.code
                    ? GlobalColors.primary
                    : Colors.transparent,
              ),
            ),
            child: Theme(
              data: ThemeData().copyWith(
                 radioTheme: RadioThemeData(
                  fillColor: MaterialStatePropertyAll(GlobalColors.darkGray),
                )
              ),
              child: RadioListTile(
                value: data.code,
                groupValue: controller.currentLanguage.value,
                onChanged: (v) {
                  controller.confirmChangeLanguage(v);
                },
                controlAffinity: ListTileControlAffinity.trailing,
                title: Row(
                  children: [
                    Image.asset(
                      data.icon,
                      height: 24.h,
                      width: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      data.name.tr,
                      style: GlobalTextStyles.font15w500,
                    ),
                  ],
                ),
                activeColor: GlobalColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
