import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Widget untuk divider dengan text di tengah
class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, this.text = 'atau'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.borderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.borderColor)),
      ],
    );
  }
}
