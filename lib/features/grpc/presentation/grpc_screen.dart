import 'package:flutter/material.dart';

import '../../../core/presentation/devroute_ui.dart';
import '../../../core/theme/app_theme.dart';

/// Desktop presentation shell for the existing descriptor, invocation, and
/// persistence services. Service binding remains intentionally outside this
/// presentation-only redesign.
class GrpcScreen extends StatefulWidget {
  const GrpcScreen({super.key});

  @override
  State<GrpcScreen> createState() => _GrpcScreenState();
}

class _GrpcScreenState extends State<GrpcScreen> {
  var _requestTab = 0;
  var _responseTab = 0;
  final _endpoint = TextEditingController();
  final _request = TextEditingController(text: '{\n  \n}');
  final _metadata = TextEditingController(text: '{}');

  @override
  void dispose() {
    _endpoint.dispose();
    _request.dispose();
    _metadata.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const DevRouteSectionHeader(
        title: 'gRPC',
        subtitle:
            'Inspect services, compose typed requests, and review stream events.',
        actions: [
          DevRouteStatusBadge(
            'No service selected',
            tone: DevRouteStatusTone.neutral,
          ),
        ],
      ),
      const SizedBox(height: DevRouteSpacing.md),
      Expanded(
        child: DevRouteSplitView(
          initialRatio: .27,
          minFirst: 220,
          first: DevRoutePanel(
            padding: EdgeInsets.zero,
            header: const DevRoutePanelHeader(
              title: 'Services & methods',
              subtitle: 'Reflection or imported descriptors',
              trailing: Icon(Icons.add, size: 18),
            ),
            child: const DevRouteEmptyState(
              icon: Icons.schema_outlined,
              title: 'No descriptors loaded',
              message:
                  'Import a descriptor set or connect to server reflection to browse services.',
            ),
          ),
          second: Column(
            children: [
              DevRouteToolbar(
                children: [
                  SizedBox(
                    width: 360,
                    height: 34,
                    child: TextField(
                      controller: _endpoint,
                      decoration: const InputDecoration(
                        hintText: 'localhost:50051',
                        prefixIcon: Icon(Icons.dns_outlined, size: 17),
                        isDense: true,
                      ),
                    ),
                  ),
                  const DevRouteStatusBadge(
                    'Unary',
                    tone: DevRouteStatusTone.info,
                  ),
                  const DevRouteToolbarButton(
                    label: 'Invoke',
                    icon: Icons.play_arrow,
                    onPressed: null,
                    primary: true,
                  ),
                  const DevRouteToolbarButton(
                    label: 'Cancel',
                    icon: Icons.stop_circle_outlined,
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: DevRouteSpacing.sm),
              Expanded(
                child: DevRouteSplitView(
                  initialRatio: .5,
                  first: DevRoutePanel(
                    padding: EdgeInsets.zero,
                    header: const DevRoutePanelHeader(
                      title: 'Request',
                      subtitle: 'Typed JSON message and metadata',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DevRouteTabs(
                          tabs: const ['Message', 'Metadata'],
                          selectedIndex: _requestTab,
                          onSelected: (value) =>
                              setState(() => _requestTab = value),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(DevRouteSpacing.sm),
                            child: TextField(
                              controller: _requestTab == 0
                                  ? _request
                                  : _metadata,
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                              decoration: const InputDecoration(
                                alignLabelWithHint: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  second: DevRoutePanel(
                    padding: EdgeInsets.zero,
                    header: const DevRoutePanelHeader(
                      title: 'Response',
                      subtitle: 'Messages, stream events, and replay history',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DevRouteTabs(
                          tabs: const ['Response', 'Stream events', 'History'],
                          selectedIndex: _responseTab,
                          onSelected: (value) =>
                              setState(() => _responseTab = value),
                        ),
                        const Expanded(
                          child: DevRouteEmptyState(
                            icon: Icons.swap_calls,
                            title: 'Ready for a gRPC call',
                            message:
                                'Select a discovered method to enable invocation and response inspection.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
