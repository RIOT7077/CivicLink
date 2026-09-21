import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'department_issue_details_screen.dart';

class ResolvedIssuesScreen extends StatelessWidget {
  final String department;

  const ResolvedIssuesScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('assignedTo', isEqualTo: department)
          .where('status', isEqualTo: 'Resolved')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No resolved issues'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            // ✅ DEFINE data HERE
            final data = doc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(data['title'] ?? 'Untitled'),
              subtitle: const Text('Resolved'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DepartmentIssueDetailsScreen(
                      issueId: doc.id,
                      issueData: data, // ✅ NOW VALID
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
