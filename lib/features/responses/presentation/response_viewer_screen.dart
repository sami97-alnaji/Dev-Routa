import 'package:flutter/material.dart';
import '../../../shared/components/feature_placeholder_screen.dart';

class ResponseViewerScreen extends StatelessWidget {
  const ResponseViewerScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholderScreen(
    title: 'Response viewer',
    description: 'Response inspection module.',
    icon: Icons.data_object,
  );
}
