import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'department_issue_details_screen.dart';

class FieldVisitIssuesScreen extends StatelessWidget {
  final String department;

  const FieldVisitIssuesScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const textPrimary = Color(0xFF1E293B);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('assignedTo', isEqualTo: department)
          .where('status', isEqualTo: 'Field Visit Scheduled')
          .snapshots(),
      builder: (context, snapshot) {
        /// LOADING
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        /// EMPTY
        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'No field visits scheduled',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        /// DATA
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,

          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Icon(Icons.event, color: Colors.white),
                ),

                title: Text(
                  data['title'] ?? 'Untitled Issue',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Field Visit Scheduled',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DepartmentIssueDetailsScreen(
                        issueId: doc.id,
                        issueData: data,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
