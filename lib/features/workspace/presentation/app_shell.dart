import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/dio_request_execution_service.dart';
import '../../../shared/models/api_models.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialSection = 0});
  final int initialSection;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _urlController = TextEditingController(text: 'https://httpbin.org/get');
  final _service = DioRequestExecutionService();
  late int _selected = widget.initialSection;
  HttpMethod _method = HttpMethod.get;
  ApiResponseModel? _response;
  bool _sending = false;
  static const _titles = <String>[
    'Workspace',
    'New request',
    'History',
    'Environments',
    'AI tools',
    'Settings',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = _content();
    if (MediaQuery.sizeOf(context).width < 900) {
      return Scaffold(
        appBar: AppBar(title: const Text('DevRoute AI Studio')),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selected,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.send_outlined),
              label: 'Request',
            ),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(icon: Icon(Icons.tune), label: 'Env'),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              label: 'AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: _selected,
            onDestinationSelected: _select,
            leading: const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'DevRoute',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.grid_view_outlined),
                label: Text('Workspace'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.send_outlined),
                label: Text('New request'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.tune),
                label: Text('Environments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                label: Text('AI tools'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  void _select(int index) => setState(() => _selected = index);
  Widget _content() => Padding(
    padding: const EdgeInsets.all(24),
    child: switch (_selected) {
      0 => _workspace(),
      1 => _request(),
      _ => _placeholder(_titles[_selected]),
    },
  );
  Widget _workspace() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('My workspace', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 20),
      const Card(
        child: ListTile(
          leading: Icon(Icons.folder_outlined),
          title: Text('Collections'),
          subtitle: Text('Persistence is the next local-first increment.'),
          trailing: Icon(Icons.add),
        ),
      ),
      const SizedBox(height: 12),
      const Card(
        child: ListTile(
          leading: Icon(Icons.language_outlined),
          title: Text('Active environment'),
          subtitle: Text('No environment selected'),
        ),
      ),
    ],
  );
  Widget _request() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Request builder',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          DropdownButton<HttpMethod>(
            value: _method,
            items: HttpMethod.values
                .take(5)
                .map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(method.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (method) => setState(() => _method = method!),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://api.example.com/resource',
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _sending ? null : _send,
            child: Text(_sending ? 'Sending…' : 'Send'),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Expanded(child: _responseViewer()),
    ],
  );
  Widget _responseViewer() {
    final response = _response;
    if (response == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Send a request to view its status, headers, body, and timing.',
          ),
        ),
      );
    }
    final text = response.error ?? response.body;
    final label = response.error != null
        ? 'Request error'
        : '${response.statusCode ?? '—'} ${response.statusMessage ?? ''}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${response.durationMs} ms • ${response.sizeBytes} bytes'),
            const Divider(),
            Expanded(child: SingleChildScrollView(child: SelectableText(text))),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final now = DateTime.now();
    setState(() {
      _sending = true;
      _response = null;
    });
    final request = ApiRequestModel(
      id: const Uuid().v4(),
      createdAt: now,
      updatedAt: now,
      name: 'Untitled request',
      url: _urlController.text.trim(),
      method: _method,
    );
    final response = await _service.execute(request);
    if (!mounted) return;
    setState(() {
      _response = response;
      _sending = false;
    });
  }

  Widget _placeholder(String title) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _selected == 4
              ? Icons.auto_awesome_outlined
              : Icons.construction_outlined,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'This feature is scheduled for a later implementation increment.',
        ),
      ],
    ),
  );
}
