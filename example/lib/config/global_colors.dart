import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class GlobalColors {
  static Color primary =  const Color(0xFF4B8CE6);
  static Color gray = HexColor("#636366");
  static Color darkBlue = HexColor("#0051A3");
  static Color lightBlue = HexColor("#ebf5ff");
  static Color lightGray = HexColor("#F5F5F5");
  static Color darkGray = HexColor("#AEAEB2");
  static Color backgroundColor = HexColor("#EAF1F6");
  static Color bgAd = const Color.fromARGB(255, 199, 222, 238);
  static Color iconColor = HexColor("#8E8E93");
  static Color txtGray = const Color(0xFF8E8E93);
  static Color erroBg = HexColor("#FEE9E7");
  static Color erroBorder = HexColor("#F86B5B");
  static Color homeOwnerInsuColor = HexColor("#BF5AF2");
  static Color pmiColor = HexColor("#597FE5");
  static Color propertyColor = HexColor("#FF9500");
  static Color principalInterestColor = HexColor("#07C07E");  
  static Color btnNotNowRate = const Color(0xFF8A94AD);
  static Color titleRate = const Color(0xFF171725);
  static Color desRate = const Color(0xFF525B75);
  static Color starRate = const Color(0xFFFFB400);
  static Color dontHaveWorldClock = const Color(0xFF636366);
  static Color titleWorldClock = const Color(0xFF2C2C2E);
  static Color btnPrimary = const Color(0xFF186EE7);
  static Color btnCancel = HexColor("#F2F2F2"); 
  static Color btnDelete = const Color(0xFFFF453A);
  static Color devider = HexColor("#E5E5EA"); 
}