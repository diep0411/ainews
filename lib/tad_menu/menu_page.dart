import 'package:ai_new/tad_menu/historiesPage.dart';
import 'package:ai_new/tad_menu/savePage.dart';
import 'package:ai_new/tad_menu/sourcesPage.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                icon: Icons.newspaper_outlined,
                title: 'News Sources',
                onTap: () => _openPage(context, const Sourcespage()),
              ),
              _buildDivider(),
              _buildMenuTile(
                context: context,
                icon: Icons.history,
                title: 'Histories',
                onTap: () => _openPage(context, const HistoriesPage()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSectionHeader('GENERAL'),
          _buildCard(
            children: [
              _buildMenuTile(
                context: context,
                icon: Icons.public,
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
                trailingIcon: Icons.open_in_new,
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
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2F5BEA),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0));
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
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Icon(icon, size: 19, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF191919),
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )
          : Icon(
              trailingIcon ?? Icons.chevron_right,
              size: 18,
              color: Colors.grey.shade400,
            ),
      visualDensity: const VisualDensity(vertical: -1.5),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
