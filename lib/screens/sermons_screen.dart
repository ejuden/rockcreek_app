// Sermons tab — fetches and displays a scrollable list of sermons.
//
// Data flow:
// 1. On init, calls ApiService.fetchSermons() to get sermon list.
// 2. FutureBuilder shows a spinner while loading, error state on failure.
// 3. Pull-to-refresh re-fetches the sermon list.
// 4. Tapping a sermon navigates to SermonDetailScreen.
//
// If the sermon list appears empty or wrong, check ApiService selectors.
import 'package:flutter/material.dart';
import '../models/sermon.dart';
import '../services/api_service.dart';
import '../widgets/loading_indicator.dart';
import 'sermon_detail_screen.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  late Future<List<Sermon>> _sermonsFuture;

  @override
  void initState() {
    super.initState();
    _sermonsFuture = ApiService.fetchSermons();
  }

  void _refresh() {
    setState(() {
      _sermonsFuture = ApiService.fetchSermons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sermon>>(
      future: _sermonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load sermons.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final sermons = snapshot.data ?? [];

        if (sermons.isEmpty) {
          return const Center(child: Text('No sermons found.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            _refresh();
          },
          child: ListView.separated(
            itemCount: sermons.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sermon = sermons[index];
              return _SermonListTile(
                sermon: sermon,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SermonDetailScreen(sermon: sermon),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _SermonListTile extends StatelessWidget {
  final Sermon sermon;
  final VoidCallback onTap;

  const _SermonListTile({required this.sermon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(30),
        child: Icon(Icons.play_arrow, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        sermon.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: _buildSubtitle(),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget? _buildSubtitle() {
    final parts = <String>[];
    if (sermon.speaker != null) parts.add(sermon.speaker!);
    if (sermon.date != null) {
      final parsed = DateTime.tryParse(sermon.date!);
      if (parsed != null) {
        parts.add(
          '${parsed.month}/${parsed.day}/${parsed.year}',
        );
      }
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' • '));
  }
}
