import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'department_issue_details_screen.dart';

class InProgressIssuesScreen extends StatelessWidget {
  final String department;

  const InProgressIssuesScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('assignedTo', isEqualTo: department)
          .where('status', isEqualTo: 'In Progress')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No ongoing issues'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['title']),
              subtitle: const Text('Work in progress'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DepartmentIssueDetailsScreen(
                      issueId: doc.id,
                      issueData: data, // ✅ keep passing this
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
