/// VELT — main entry point
/// Wires theme controller to MaterialApp.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'state/theme_controller.dart';

void main() => runApp(const VeltApp());

class VeltApp extends StatelessWidget {
  const VeltApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VELT',
            theme:     AppTheme.of(themeController.current),
            darkTheme: AppTheme.of(themeController.current),
            themeMode: ThemeMode.dark,
            home: const _Placeholder(),
          );
        },
      ),
    );
  }
}

/// Placeholder root — replace with TabShell + BottomNav in production.
class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('VELT', style: TextStyle(
              fontSize: 72, fontWeight: FontWeight.w700,
              color: c.accentIron, letterSpacing: -4,
            )),
            const SizedBox(height: 16),
            Text('Theme system wired.\nBuild screens next.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textSecondary)),
          ],
        ),
      )),
    );
  }
}
