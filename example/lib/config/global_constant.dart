import 'package:flutter/material.dart';
import 'package:example/language/l.dart';

class GlobalConstants {
  static const String kAppName = 'App Test';
  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('de'),
    Locale('fr'),
    Locale('hi'),
    Locale('es'),
    Locale('id'),
  ];
}

class LoanType{
  static const String personalLoan = L.personalLoan;
  static const String bussinessLoan = L.businessLoan;
  static const String mortgages = L.mortgages;
  static const String autoLoan = L.autoLoan;
}

class InvestmentType{
  static const String fd = L.fixDeposit;
  static const String rd = L.recurringDeposit;
}
