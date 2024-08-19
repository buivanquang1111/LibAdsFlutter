import 'dart:io';

import 'package:amazic_ads_flutter/src/utils/preferences_util.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DetectTestAd {
  var testAd = 'Test Ad';

  DetectTestAd._DetectTestAd();

  static final DetectTestAd instance = DetectTestAd._DetectTestAd();

  bool isTestAd() {
    return PreferencesUtil.isTestAd();
  }

  void detectImageToText(
      {required File imageFile,
      required Function() onSuccess,
      required Function(String) onError}) async {
    try {
      // Load the image using Google ML Kit
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Extract recognized text
      String text = recognizedText.text;

      print('showTextHehe: $text');
      if (text.toLowerCase().contains(testAd.toLowerCase())) {
        PreferencesUtil.setTestAd();
        onSuccess();
      } else {
        onError('ad real');
      }
    } catch (e) {
      print('showTextHehe: Error occurred: $e');
      onError('$e');
    }
  }
}
