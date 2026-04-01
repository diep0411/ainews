import 'package:flutter/material.dart';
import 'package:ai_new/services/histories_service.dart';
import 'package:ai_new/services/report_service.dart';

class HistoriesPage extends StatefulWidget {
  const HistoriesPage({super.key});

  @override
  State<HistoriesPage> createState() => _HistoriesPageState();
}

class _HistoriesPageState extends State<HistoriesPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ReportService.reportsVersion,
      builder: (context, _, __) {
        final histories = ReportService.filterUnreported(
          HistoryService.histories,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Histories'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    HistoryService.clear();
                  });
                },
              ),
            ],
          ),
          body: histories.isEmpty
              ? const Center(child: Text("No history yet"))
              : ListView.builder(
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final item = histories[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: item.imageUrl != null
                                  ? Image.network(
                                      item.imageUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image, size: 50),
                                    ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.sourceName ?? "Unknown source",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
