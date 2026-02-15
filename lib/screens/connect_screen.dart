// Connect tab — static contact info with action buttons.
//
// Displays church address, phone, email, and website as tappable cards.
// Each card launches the appropriate native app (Maps, Phone, Mail, Browser).
// All contact details are stored in AppConfig.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  Future<void> _openMap() async {
    final uri = Uri.parse(AppConfig.mapUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.people,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Connect With Us',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),

          // Address
          _ContactCard(
            icon: Icons.location_on,
            title: 'Address',
            subtitle: AppConfig.churchAddress,
            onTap: _openMap,
            buttonLabel: 'Open in Maps',
          ),
          const SizedBox(height: 16),

          // Phone
          _ContactCard(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: AppConfig.churchPhone,
            onTap: () => _openUrl('tel:${AppConfig.churchPhone}'),
            buttonLabel: 'Call',
          ),
          const SizedBox(height: 16),

          // Email
          _ContactCard(
            icon: Icons.email,
            title: 'Email',
            subtitle: AppConfig.churchEmail,
            onTap: () => _openUrl('mailto:${AppConfig.churchEmail}'),
            buttonLabel: 'Send Email',
          ),
          const SizedBox(height: 16),

          // Website
          _ContactCard(
            icon: Icons.language,
            title: 'Website',
            subtitle: AppConfig.churchWebsite,
            onTap: () => _openUrl(AppConfig.churchWebsite),
            buttonLabel: 'Visit Website',
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String buttonLabel;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onTap,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
