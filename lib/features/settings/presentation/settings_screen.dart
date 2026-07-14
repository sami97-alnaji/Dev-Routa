import 'package:flutter/material.dart';
import '../../../shared/components/feature_placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholderScreen(
    title: 'Settings',
    description: 'Application settings module.',
    icon: Icons.settings_outlined,
  );
}
