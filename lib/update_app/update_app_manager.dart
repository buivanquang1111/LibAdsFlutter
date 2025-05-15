import 'package:amazic_ads_flutter/update_app/dialog_update_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateAppManager {
  UpdateAppManager._instance();

  static final UpdateAppManager instance = UpdateAppManager._instance();

  checkForFlexibleUpdate({
    required BuildContext context,
    String? title,
    String? content,
    required Function() onNext,
  }) async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        try {
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: DialogUpdateApp(
                    title: title,
                    content: content,
                    onUpdateNow: () async {
                      if (context.mounted) Navigator.of(context).pop();
                      try {
                        onNext();
                        await InAppUpdate.startFlexibleUpdate();
                        await InAppUpdate.completeFlexibleUpdate();
                        Fluttertoast.showToast(msg: 'Updated and ready – welcome back!');
                      } catch (e) {
                        print('update_app --- error update failed: $e');
                        onNext();
                      }
                    },
                  ),
                );
              },
            );
          }
        } catch (e) {
          print('update_app --- error update failed (inner try): $e');
          if (context.mounted) onNext();
        }
      } else {
        print('update_app --- new update');
        if (context.mounted) onNext();
      }
    } catch (e) {
      print('update_app --- error checking for update: $e');
      if (context.mounted) onNext();
    }
    // finally {
    //   if (context.mounted) {
    //     Future.delayed(const Duration(milliseconds: 200), () {
    //       print('update_app --- finally for update');
    //       onNext();
    //     });
    //   }
    // }
  }



// checkForImmediateUpdate({required BuildContext context, required String title, required String content}) async {
//   try {
//     AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
//
//     if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//       try {
//         showDialog(
//           context: context,
//           builder: (context) {
//             return DialogUpdateApp(
//               title: title,
//               content: content,
//               onUpdateNow: () async{
//                 await InAppUpdate.performImmediateUpdate();
//               },
//             );
//           },
//         );
//       } catch (e) {
//         print('error update failed: $e');
//       }
//     }
//   } catch (e) {
//     print('error checking for update: $e');
//   }
// }
}
