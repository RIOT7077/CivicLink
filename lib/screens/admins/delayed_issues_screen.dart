import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DelayedIssuesScreen extends StatelessWidget {
  const DelayedIssuesScreen({super.key});

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
          'Delayed & Critical Issues',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .where('status', whereIn: ['Submitted', 'Assigned'])
            .snapshots(),
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
          final now = DateTime.now();

          final delayedIssues = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['createdAt'] == null) return false;

            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final daysPending = now.difference(createdAt).inDays;

            final priority = data['priority'] ?? 'Low';

            return daysPending > 7 || (priority == 'Critical');
          }).toList();

          /// EMPTY STATE
          if (delayedIssues.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.green,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No delayed or critical issues 🎉',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          /// DATA
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: delayedIssues.length,
            itemBuilder: (context, index) {
              final doc = delayedIssues[index];
              final data = doc.data() as Map<String, dynamic>;

              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final daysPending = now.difference(createdAt).inDays;

              final priority = data['priority'] ?? 'Low';
              final bool isCritical = priority == 'Critical';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(14),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ICON
                      CircleAvatar(
                        backgroundColor: isCritical
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                        child: Icon(
                          isCritical
                              ? Icons.warning_amber_rounded
                              : Icons.access_time,
                          color: isCritical ? Colors.red : Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// ISSUE DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'Untitled Issue',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textPrimary,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Priority: $priority",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "$daysPending days",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            if (data['assignedTo'] != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.apartment,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['assignedTo'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      /// STATUS CHIP
                      Chip(
                        label: Text(
                          isCritical ? 'URGENT' : 'DELAYED',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: isCritical
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
