import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'department_issue_details_screen.dart';

class PendingIssuesScreen extends StatelessWidget {
  final String department;

  const PendingIssuesScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const textPrimary = Color(0xFF1E293B);
    print("🔥 Department received in PendingScreen: $department");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('assignedTo', isEqualTo: department)
          .where('status', isEqualTo: 'Assigned')
          .snapshots(),
      builder: (context, snapshot) {
        /// LOADING
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print("🔥 Firestore assignedTo: ${data['assignedTo']}");
          print("🔥 Firestore status: ${data['status']}");
        }

        /// EMPTY
        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending_actions, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text('No pending issues', style: TextStyle(fontSize: 16)),
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

            final priority = data['priority'] ?? 'Low';

            Color priorityColor;

            switch (priority) {
              case "Critical":
                priorityColor = Colors.red;
                break;
              case "High":
                priorityColor = Colors.orange;
                break;
              case "Medium":
                priorityColor = Colors.amber;
                break;
              default:
                priorityColor = Colors.green;
            }

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Icon(Icons.pending_actions, color: Colors.white),
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
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Priority: $priority',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
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
