import 'package:flutter/material.dart';
import '../../../shared/components/feature_placeholder_screen.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholderScreen(
    title: 'AI tools',
    description: 'Consent-based AI analysis module.',
    icon: Icons.auto_awesome_outlined,
  );
}
