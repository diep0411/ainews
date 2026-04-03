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
            title: const Text(
              'Histories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
              ? Center(
                  child: Text(
                    'No history yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final item = histories[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            item.imageUrl != null
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
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.sourceName ?? 'Unknown source',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${HistoryService.accessedAgoLabel(item)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
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
