import 'package:flutter/material.dart';
import '../../../shared/components/feature_placeholder_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholderScreen(
    title: 'History',
    description: 'Local request history module.',
    icon: Icons.history,
  );
}
