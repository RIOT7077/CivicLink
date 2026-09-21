import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CitizenIssueDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> issueData;

  const CitizenIssueDetailsScreen({super.key, required this.issueData});

  Future<void> _openLocation(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Resolved":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = issueData['status'];

    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);
    const textPrimary = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Issue Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// ISSUE INFORMATION CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Issue Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      issueData['title'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(issueData['description']),

                    const SizedBox(height: 8),

                    Text("Type: ${issueData['issueType']}"),

                    const SizedBox(height: 10),

                    /// STATUS BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// SUBMITTED IMAGE
            if (issueData['imageUrl'] != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Submitted Image',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          issueData['imageUrl'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// LOCATION CARD
            if (issueData.containsKey('locationUrl'))
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: const Text('View Issue Location'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openLocation(issueData['locationUrl']),
                ),
              ),

            const SizedBox(height: 20),

            /// STATUS TIMELINE
            if (issueData.containsKey('statusHistory')) ...[
              const Text(
                'Status Timeline',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...List.from(issueData['statusHistory']).map((item) {
                final ts = (item['timestamp'] as Timestamp).toDate();

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(item['status']),
                    subtitle: Text(ts.toString()),
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 20),

            /// RESOLUTION DETAILS
            if (status == 'Resolved') ...[
              const Text(
                'Resolution Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (issueData['departmentRemark'] != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      issueData['departmentRemark'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              if (issueData['resolvedImageUrl'] != null)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resolution Proof',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            issueData['resolvedImageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
