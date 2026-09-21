import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentAnalyticsScreen extends StatelessWidget {
  final String department;

  const DepartmentAnalyticsScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$department Analytics'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .where('assignedTo', isEqualTo: department)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final issues = snapshot.data!.docs;

          int total = issues.length;
          int assigned = 0;
          int fieldVisit = 0;
          int inProgress = 0;
          int resolved = 0;

          int totalResolutionHours = 0;
          int resolvedCount = 0;

          for (var doc in issues) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'];

            if (status == 'Assigned') assigned++;
            if (status == 'Field Visit Scheduled') fieldVisit++;
            if (status == 'In Progress') inProgress++;
            if (status == 'Resolved') resolved++;

            if (data['createdAt'] != null && data['resolvedAt'] != null) {
              final created = (data['createdAt'] as Timestamp).toDate();
              final resolvedAt = (data['resolvedAt'] as Timestamp).toDate();

              totalResolutionHours += resolvedAt.difference(created).inHours;
              resolvedCount++;
            }
          }

          final avgResolution = resolvedCount == 0
              ? 0
              : (totalResolutionHours ~/ resolvedCount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 KPI CARDS
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    _kpiCard(
                      title: 'Total Issues',
                      value: total.toString(),
                      icon: Icons.list_alt,
                      color: Colors.blue,
                    ),
                    _kpiCard(
                      title: 'Resolved',
                      value: resolved.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _kpiCard(
                      title: 'In Progress',
                      value: inProgress.toString(),
                      icon: Icons.build_circle,
                      color: Colors.orange,
                    ),
                    _kpiCard(
                      title: 'Avg Resolution',
                      value: '$avgResolution hrs',
                      icon: Icons.timer,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔹 STATUS DISTRIBUTION
                const Text(
                  'Issue Status Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _statusBar(
                  label: 'Assigned',
                  count: assigned,
                  total: total,
                  color: Colors.orange,
                ),
                _statusBar(
                  label: 'Field Visit',
                  count: fieldVisit,
                  total: total,
                  color: Colors.purple,
                ),
                _statusBar(
                  label: 'In Progress',
                  count: inProgress,
                  total: total,
                  color: Colors.blue,
                ),
                _statusBar(
                  label: 'Resolved',
                  count: resolved,
                  total: total,
                  color: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================
  // KPI CARD
  // =========================
  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // =========================
  // STATUS BAR
  // =========================
  Widget _statusBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final double percent = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ($count)'),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }
}
