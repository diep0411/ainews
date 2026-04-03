import 'package:ai_new/tad_menu/historiesPage.dart';
import 'package:ai_new/tad_menu/savePage.dart';
import 'package:ai_new/tad_menu/sourcesPage.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  static const Color _pageBg = Color( 0xFFFFFFFF);
  static const Color _cardBg = Color(0xFFF6F3F2);
  static const Color _sectionBlue = Color(0xFF1B4DD9);
  static const Color _titleColor = Color(0xFF202125);
  static const Color _iconColor = Color(0xFF8E93A8);
  static const Color _subtleText = Color(0xFF8C93A8);
  static const Color _dividerColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 36 / 2,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
        children: [
          _buildSectionHeader('CURATION'),
          _buildCard(
            children: [
              _buildMenuTile(
                context: context,
                icon: Icons.bookmark_border,
                title: 'Saved Articles',
                onTap: () => _openPage(context, const SavePage()),
              ),
              _buildDivider(),
              _buildMenuTile(
                context: context,
                icon: Icons.folder_open_outlined,
                title: 'News Sources',
                onTap: () => _openPage(context, const Sourcespage()),
              ),
              _buildDivider(),
              _buildMenuTile(
                context: context,
                icon: Icons.history_outlined,
                title: 'Histories',
                onTap: () => _openPage(context, const HistoriesPage()),
              ),
            ],
          ),
          const SizedBox(height: 42),
          _buildSectionHeader('GENERAL'),
          _buildCard(
            children: [
              _buildMenuTile(
                context: context,
                icon: Icons.language_outlined,
                title: 'Language',
                trailingText: 'ENGLISH (US)',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language settings coming soon'),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuTile(
                context: context,
                icon: Icons.star_border,
                title: 'Rate App',
                trailingIcon: Icons.open_in_new_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rate App feature coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: _sectionBlue,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.4,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 7, thickness: 7, color: _dividerColor);
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? trailingText,
    IconData? trailingIcon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 64,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      leading: Icon(icon, size: 21, color: _iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 31 / 2,
          fontWeight: FontWeight.w600,
          color: _titleColor,
        ),
      ),
      trailing: trailingText != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailingText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right, size: 18, color: _iconColor),
              ],
            )
          : Icon(
              trailingIcon ?? Icons.chevron_right,
              size: 18,
              color: _iconColor,
            ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
