// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:example/config/global_colors.dart';
import 'package:example/const/resource.dart';

class AppScafold extends StatelessWidget {
  final bool isDecor;
  final bool isHome;
  final Widget body;
  final bool isPortrait;
  final PreferredSizeWidget? appBar;
  final double appBarHeight;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  const AppScafold({
    super.key,
    this.appBar,
    this.appBarHeight = kToolbarHeight,
    required this.isHome,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    required this.isDecor,
    required this.isPortrait,
    required this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: appBarHeight + 97 + MediaQuery.of(context).viewPadding.top,
            width: MediaQuery.sizeOf(context).width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.52, -0.86),
                end: Alignment(-0.52, 0.86),
                colors: [
                  Color(0xFF1552D1),
                  Color(0xFF4B7DE6),
                ],
              ),
            ),
          ),
          if (isDecor)
            Image.asset(
              R.ASSETS_IMAGES_APP_BAR_DECOR_PNG,
              width: MediaQuery.sizeOf(context).width,
              fit: BoxFit.fitWidth,
            ),
          if (appBar != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: appBar!,
            ),
          Column(
            children: [
              if (isHome)
                SizedBox(
                  height: appBarHeight +
                      73 +
                      MediaQuery.of(context).viewPadding.top,
                )
              else
                SizedBox(
                  height: appBarHeight +
                      32 +
                      MediaQuery.of(context).viewPadding.top,
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor ?? GlobalColors.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                height:
                    appBarHeight + 32 + MediaQuery.of(context).viewPadding.top,
              ),
              Expanded(child: body),
            ],
          ),
        ],
      ),
    );
  }
}
