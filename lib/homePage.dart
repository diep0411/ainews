import 'package:ai_new/services/save_service.dart';
import 'package:ai_new/tadBarpage/business.dart';
import 'package:ai_new/tadBarpage/climate.dart';
import 'package:ai_new/tadBarpage/technology.dart';
import 'package:ai_new/tad_menu/historiesPage.dart';
import 'package:ai_new/tad_menu/savePage.dart';
import 'package:ai_new/tad_menu/sourcesPage.dart';
import 'package:flutter/material.dart';
import 'tadBarpage/all_articles.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/All_top.png', fit: BoxFit.cover),
                    const Positioned(
                      bottom: 20,
                      left: 16,
                      child: Text(
                        'MENU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                child: Text(
                  'Curation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              _funcMenu(
                context,
                const Icon(Icons.bookmark_border, size: 24, color: Colors.grey),
                'Saved Articles',
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                const SavePage(),
              ),
              _funcMenu(
                context,
                const Icon(Icons.history, size: 24, color: Colors.grey),
                'Histories',
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                const HistoriesPage(),
              ),
              _funcMenu(
                context,
                const Icon(Icons.source_outlined, size: 24, color: Colors.grey),
                'News Cources',
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                const Sourcespage(),
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                child: Text(
                  'General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              _funcMenu(
                context,
                const Icon(Icons.public_outlined, size: 24, color: Colors.grey),
                'Language',
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                const SettingsPage(),
              ),
              _funcMenu(
                context,
                const Icon(Icons.star_border, size: 24, color: Colors.grey),
                'Rate App',
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                const SettingsPage(),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          title: const Text(
            'ARCHITECT',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              color: Colors.blue,
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'ALL'),
              Tab(text: 'TECHNOLOGY'),
              Tab(text: 'BUSINESS'),
              Tab(text: 'CLIMATE'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const TabBarView(
            children: [
              AllArticles(),
              TechnologyPage(),
              BusinessPage(),
              ClimatePage(),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _funcMenu(
    BuildContext context,
    Icon icon,
    String title,
    Icon icon2,
    Widget page,
  ) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: icon,
      title: Text(title),
      trailing: icon2,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SwitchListTile(
            value: true,
            onChanged: null,
            title: Text('Notifications'),
          ),
          ListTile(leading: Icon(Icons.color_lens), title: Text('Theme')),
          ListTile(leading: Icon(Icons.info), title: Text('About')),
        ],
      ),
    );
  }
}
