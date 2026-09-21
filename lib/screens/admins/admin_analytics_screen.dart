import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);
    const textPrimary = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('issues').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final issues = snapshot.data!.docs;

          int total = issues.length;
          int submitted = 0;
          int assigned = 0;
          int resolved = 0;

          Map<String, int> departmentCount = {};
          int totalResolutionHours = 0;
          int resolvedCount = 0;

          for (var doc in issues) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'];

            if (status == 'Submitted') submitted++;
            if (status == 'Assigned') assigned++;
            if (status == 'Resolved') resolved++;

            if (data['assignedTo'] != null) {
              final dept = data['assignedTo'];
              departmentCount[dept] = (departmentCount[dept] ?? 0) + 1;
            }

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
                /// KPI SECTION
                const Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
                      title: 'Assigned',
                      value: assigned.toString(),
                      icon: Icons.assignment,
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

                const SizedBox(height: 30),

                /// STATUS DISTRIBUTION
                const Text(
                  'Issue Status Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                _statusBar(
                  label: 'Submitted',
                  count: submitted,
                  total: total,
                  color: Colors.grey,
                ),
                _statusBar(
                  label: 'Assigned',
                  count: assigned,
                  total: total,
                  color: Colors.orange,
                ),
                _statusBar(
                  label: 'Resolved',
                  count: resolved,
                  total: total,
                  color: Colors.green,
                ),

                const SizedBox(height: 30),

                /// DEPARTMENT WORKLOAD
                const Text(
                  'Department Workload',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                ...departmentCount.entries.map(
                  (entry) => Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2563EB),
                        child: Icon(Icons.apartment, color: Colors.white),
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// KPI CARD
  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// STATUS BAR
  Widget _statusBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final double percent = total == 0
        ? 0.0
        : count.toDouble() / total.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ($count)',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
