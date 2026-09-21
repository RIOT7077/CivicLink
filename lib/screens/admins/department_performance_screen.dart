import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentPerformanceScreen extends StatelessWidget {
  const DepartmentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);
    const textPrimary = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Department Performance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('issues').snapshots(),
        builder: (context, snapshot) {
          /// ERROR
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final Map<String, _DepartmentStats> stats = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final assignedTo = data['assignedTo'];
            if (assignedTo == null || assignedTo is! String) {
              continue;
            }

            stats.putIfAbsent(assignedTo, () => _DepartmentStats());
            stats[assignedTo]!.total++;

            if (data['status'] == 'Resolved') {
              stats[assignedTo]!.resolved++;

              if (data['createdAt'] != null && data['resolvedAt'] != null) {
                final created = (data['createdAt'] as Timestamp).toDate();
                final resolved = (data['resolvedAt'] as Timestamp).toDate();

                stats[assignedTo]!.resolutionHours += resolved
                    .difference(created)
                    .inHours;
              }
            }
          }

          if (stats.isEmpty) {
            return const Center(
              child: Text(
                'No department data available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: stats.entries.map((entry) {
              final dept = entry.key;
              final stat = entry.value;

              final pending = stat.total - stat.resolved;

              final avgTime = stat.resolved == 0
                  ? 0
                  : (stat.resolutionHours ~/ stat.resolved);

              final bool needsAttention = avgTime > 72 || pending > 5;

              final double resolutionRate = stat.total == 0
                  ? 0
                  : stat.resolved / stat.total;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(14),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: needsAttention
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            child: Icon(
                              Icons.apartment,
                              color: needsAttention ? Colors.red : Colors.green,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              dept,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),

                          Chip(
                            label: Text(
                              needsAttention ? 'Needs Attention' : 'Good',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: needsAttention
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// STATS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statItem("Assigned", stat.total),
                          _statItem("Resolved", stat.resolved),
                          _statItem("Pending", pending),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Avg Resolution: $avgTime hrs",
                        style: const TextStyle(fontSize: 13),
                      ),

                      const SizedBox(height: 8),

                      /// PERFORMANCE BAR
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: resolutionRate,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation(
                            needsAttention ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// STAT ITEM
  Widget _statItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _DepartmentStats {
  int total = 0;
  int resolved = 0;
  int resolutionHours = 0;
}
