import 'package:ai_new/tadBarpage/business.dart';
import 'package:ai_new/tadBarpage/climate.dart';
import 'package:ai_new/tadBarpage/technology.dart';
import 'package:ai_new/tad_menu/menu_page.dart';
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MenuPage()),
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
}
