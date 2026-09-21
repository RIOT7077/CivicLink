import 'package:civiclink/screens/citizen/citizen_issue_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/issue_service.dart';

class MyIssuesScreen extends StatelessWidget {
  const MyIssuesScreen({super.key});

  Future<void> _openLocation(String url) async {
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url');
    }
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
    final issueService = IssueService();

    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);
    const textPrimary = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Issues',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: issueService.getMyIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No issues submitted yet',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final issue = snapshot.data!.docs[index];
              final data = issue.data() as Map<String, dynamic>;

              final status = data['status'];

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CitizenIssueDetailsScreen(issueData: data),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title + Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['title'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Description
                        Text(
                          data['description'],
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 12),

                        /// Location button
                        if (data.containsKey('locationUrl'))
                          TextButton.icon(
                            onPressed: () => _openLocation(data['locationUrl']),
                            icon: const Icon(Icons.location_on),
                            label: const Text('View Location'),
                          ),

                        const SizedBox(height: 6),

                        const Text(
                          'Tap to view full details',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
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
