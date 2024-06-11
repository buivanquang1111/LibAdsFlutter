import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? leadingWidth;
  final Widget? leading;
  final Color backgroundColor;
  final Widget? title;
  final bool? centerTitle;
  final List<Widget>? actions;
  const AppAppBar({
    super.key,
    this.leadingWidth,
    this.leading,
    this.backgroundColor = Colors.transparent,
    this.title,
    this.actions,
    this.centerTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: leadingWidth,
      leading: leading,
      backgroundColor: backgroundColor,
      title: title,
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
