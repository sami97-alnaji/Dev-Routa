import 'package:flutter/material.dart';
import '../../../shared/components/feature_placeholder_screen.dart';

class EnvironmentsScreen extends StatelessWidget {
  const EnvironmentsScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholderScreen(
    title: 'Environments',
    description: 'Environment and variable module.',
    icon: Icons.tune,
  );
}
