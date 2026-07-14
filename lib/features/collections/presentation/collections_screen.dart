import 'package:flutter/material.dart';
import '../../../shared/components/feature_placeholder_screen.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholderScreen(
    title: 'Collections',
    description: 'Collection and folder workflow module.',
    icon: Icons.folder_outlined,
  );
}
