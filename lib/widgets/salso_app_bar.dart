import 'package:flutter/material.dart';
import '../app/theme.dart';

class SalsoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const SalsoAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SalsoTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: title ?? Image.asset(
        'assets/branding/salso_logo_horizontal.png',
        height: 36,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text(
          'SALSO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: actions,
    );
  }
}
