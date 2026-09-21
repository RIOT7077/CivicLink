import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/issue_service.dart';

class IssueDetailsScreen extends StatelessWidget {
  final String issueId;
  final Map<String, dynamic> issueData;

  const IssueDetailsScreen({
    super.key,
    required this.issueId,
    required this.issueData,
  });

  Future<void> _openLocation(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showAssignDialog(BuildContext context, IssueService service) {
    final departments = [
      'Road Department',
      'Water Department',
      'Electricity Department',
      'Sanitation Department',
    ];

    String selectedDepartment = departments.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign to Department'),
              content: DropdownButtonFormField<String>(
                value: selectedDepartment,
                items: departments
                    .map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value!;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await service.assignIssueToDepartment(
                      issueId,
                      selectedDepartment,
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildStatusTimeline(List history) {
    return Column(
      children: history.map<Widget>((item) {
        final ts = (item['timestamp'] as Timestamp).toDate();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(item['status']),
            subtitle: Text(ts.toString()),
          ),
        );
      }).toList(),
    );
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
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Issue Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(issueData['submittedBy'])
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// ISSUE INFORMATION
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
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

                      const SizedBox(height: 10),

                      Text('Title: ${issueData['title']}'),
                      Text('Description: ${issueData['description']}'),
                      Text('Type: ${issueData['issueType']}'),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Status: ${issueData['status']}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// IMAGE
              if (issueData['imageUrl'] != null)
                Card(
                  elevation: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      issueData['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              /// PRIORITY
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority (Admin Override)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: issueData['priority'] ?? 'Low',
                        items: const [
                          DropdownMenuItem(value: 'Low', child: Text('Low')),
                          DropdownMenuItem(
                            value: 'Medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(value: 'High', child: Text('High')),
                          DropdownMenuItem(
                            value: 'Critical',
                            child: Text('Critical'),
                          ),
                        ],
                        onChanged: issueData['status'] == 'Resolved'
                            ? null
                            : (value) async {
                                try {
                                  await IssueService().overridePriority(
                                    issueId: issueId,
                                    newPriority: value!,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Priority updated successfully',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// LOCATION
              if (issueData.containsKey('locationUrl'))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: const Text("View Issue Location"),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openLocation(issueData['locationUrl']),
                  ),
                ),

              const SizedBox(height: 16),

              /// STATUS TIMELINE
              if (issueData.containsKey('statusHistory'))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildStatusTimeline(issueData['statusHistory']),
                  ],
                ),

              const SizedBox(height: 16),

              /// CITIZEN INFO
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Citizen Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text('Name: ${user['name']}'),
                      Text('Email: ${user['email']}'),
                      Text('Phone: ${user['phone']}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ACTION BUTTONS
              if (issueData['status'] == 'Submitted') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          await issueService.updateIssueStatus(
                            issueId,
                            'Verified',
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text(
                          'Verify',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          await issueService.updateIssueStatus(
                            issueId,
                            'Rejected',
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (issueData['status'] == 'Verified') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAssignDialog(context, issueService);
                    },
                    child: const Text(
                      'Assign to Department',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ] else if (issueData['status'] == 'Rejected') ...[
                const Text(
                  'This issue has been rejected.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
