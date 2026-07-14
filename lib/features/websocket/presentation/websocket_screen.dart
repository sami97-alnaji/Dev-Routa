import 'package:flutter/material.dart';
import '../../../shared/components/feature_placeholder_screen.dart';

class WebSocketScreen extends StatelessWidget {
  const WebSocketScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholderScreen(
    title: 'WebSocket',
    description: 'Basic WebSocket session module.',
    icon: Icons.cable,
  );
}
