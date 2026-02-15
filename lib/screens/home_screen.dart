// Home tab — mirrors the church website homepage layout.
//
// Sections (top to bottom):
// 1. Hero banner — mission statement, service times, CTA buttons
// 2. Plan Your Visit — welcome message with service times
// 3. Latest Sermon — shows the most recent sermon from the API
// 4. Beyond the Weekend — next-steps teaser
// 5. Quick Links — staff/leaders + events cards
// 6. Discipleship CTA — "Not sure where to start?" banner
//
// The latest sermon is fetched from ApiService. All other content is static.
// To update service times or text, edit the constants below.
// To change CTA URLs, update AppConfig.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/sermon.dart';
import '../services/api_service.dart';
import 'sermon_detail_screen.dart';

// ── Brand color used for the dark overlay sections ──
const _brandBlue = Color(0xFF2E86AB);
const _darkBlue = Color(0xFF1B5E7B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Sermon? _latestSermon;

  @override
  void initState() {
    super.initState();
    _loadLatestSermon();
  }

  Future<void> _loadLatestSermon() async {
    try {
      final sermons = await ApiService.fetchSermons();
      if (sermons.isNotEmpty && mounted) {
        setState(() {
          _latestSermon = sermons.first;
        });
      }
    } catch (e) {
      // Non-critical — the rest of the home screen still works without it.
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
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildPlanVisitSection(context),
          if (_latestSermon != null) _buildLatestSermonSection(context),
          _buildBeyondWeekendSection(context),
          _buildQuickLinksSection(context),
          _buildDiscipleshipSection(context),
        ],
      ),
    );
  }

  // ── 1. HERO SECTION ──
  // Full-width blue banner with mission statement, service times, and CTAs.
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_darkBlue, _brandBlue],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            Text(
              'Join us this week',
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Helping People\nMeet and Follow Jesus',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            _ServiceTimesWhite(),
            const SizedBox(height: 8),
            Text(
              'ASL Interpreted Worship at 10:00 a.m.',
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeroButton(
                  label: 'Give Now',
                  onTap: () => _openUrl(AppConfig.giveUrl),
                ),
                const SizedBox(width: 12),
                _HeroButton(
                  label: 'Join a Serve Team',
                  onTap: () => _openUrl(AppConfig.serveUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. PLAN YOUR VISIT ──
  Widget _buildPlanVisitSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            'WELCOME TO ROCK CREEK',
            style: TextStyle(
              color: _brandBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Plan Your Visit',
            style: TextStyle(
              color: _brandBlue,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Icon(Icons.calendar_today, size: 32, color: _brandBlue),
          const SizedBox(height: 16),
          Text(
            'If you\'re looking for a church in Prosper, TX, we would love '
            'for you to join us at Rock Creek Church. Experience a warm and '
            'welcoming community where you can encounter God and grow in '
            'your faith alongside others who are on the same journey.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _ServiceTimesDark(),
          const SizedBox(height: 24),
          _ActionButton(
            label: 'Plan Your Visit',
            onTap: () => _openUrl(AppConfig.planVisitUrl),
          ),
        ],
      ),
    );
  }

  // ── 3. LATEST SERMON ──
  Widget _buildLatestSermonSection(BuildContext context) {
    final sermon = _latestSermon!;
    // Format the date for display
    String dateText = '';
    if (sermon.date != null) {
      final parsed = DateTime.tryParse(sermon.date!);
      if (parsed != null) {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        dateText = '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
      }
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          // Sermon thumbnail placeholder with play icon
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: _brandBlue.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 40,
                  color: _brandBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            sermon.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _brandBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (sermon.speaker != null || dateText.isNotEmpty)
            Text(
              [
                if (sermon.speaker != null) sermon.speaker!,
                if (dateText.isNotEmpty) dateText,
              ].join(' \u2022 '),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 20),
          _ActionButton(
            label: 'View Sermon',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SermonDetailScreen(sermon: sermon),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 4. BEYOND THE WEEKEND ──
  Widget _buildBeyondWeekendSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            'Next Steps',
            style: TextStyle(
              color: _brandBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Beyond the Weekend',
            style: TextStyle(
              color: _brandBlue,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore the life of our church including our midweek '
            'ministries, upcoming events, and service opportunities.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _ActionButton(
            label: 'Learn More',
            onTap: () => _openUrl(AppConfig.nextStepsUrl),
          ),
        ],
      ),
    );
  }

  // ── 5. QUICK LINKS — Staff & Events ──
  Widget _buildQuickLinksSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Row(
        children: [
          Expanded(
            child: _QuickLinkCard(
              overline: 'MEET OUR TEAM',
              title: 'Staff &\nLeaders',
              icon: Icons.groups,
              onTap: () => _openUrl(AppConfig.meetTheTeamUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickLinkCard(
              overline: 'UPCOMING',
              title: 'Events',
              icon: Icons.event,
              onTap: () => _openUrl(AppConfig.eventsUrl),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. DISCIPLESHIP CTA ──
  Widget _buildDiscipleshipSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_darkBlue, _brandBlue],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Text(
            'Discipleship Pathway',
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Not Sure Where\nto Start?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Wherever you are on your faith journey, we invite you to take '
            'your next step with us. Discover meaningful ways to grow and '
            'connect with others!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _HeroButton(
            label: 'Start Exploring',
            onTap: () => _openUrl(AppConfig.discipleshipUrl),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──

/// Service times displayed in white text (for dark backgrounds).
class _ServiceTimesWhite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 15),
            children: [
              TextSpan(
                text: 'Saturdays',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' \u2013 5:00 p.m.'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 15),
            children: [
              TextSpan(
                text: 'Sundays',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' \u2013 8:30, 10:00, & 11:30 a.m.'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Service times displayed in dark text (for light backgrounds).
class _ServiceTimesDark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(color: Color(0xFF333333), fontSize: 15),
            children: [
              TextSpan(
                text: 'Saturdays',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' \u2013 5:00 p.m.'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: const TextSpan(
            style: TextStyle(color: Color(0xFF333333), fontSize: 15),
            children: [
              TextSpan(
                text: 'Sundays',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' \u2013 8:30, 10:00, & 11:30 a.m.'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rounded outlined button used in the hero and discipleship sections.
class _HeroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeroButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 15)),
    );
  }
}

/// Solid blue action button used in content sections.
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 15)),
    );
  }
}

/// Card widget for the quick-links row (Staff & Leaders, Events).
class _QuickLinkCard extends StatelessWidget {
  final String overline;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.overline,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: _brandBlue),
              const SizedBox(height: 12),
              Text(
                overline,
                style: TextStyle(
                  color: _brandBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: _darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
