// ignore_for_file: unused_element

import 'package:civiclink/screens/admins/admin_analytics_screen.dart';
import 'package:civiclink/screens/admins/delayed_issues_screen.dart';
import 'package:civiclink/screens/admins/department_performance_screen.dart';
import 'package:civiclink/screens/admins/issue_details_screen.dart';
import 'package:civiclink/screens/admins/user_management_screen.dart';
import 'package:civiclink/screens/department/department_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/issue_service.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign, color: Colors.white),
            tooltip: 'Announcements',
            onPressed: () {
              Navigator.pushNamed(context, '/admin-announcements');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          /// TOP DEPARTMENT BUTTONS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _squareDepartmentButton(
                  context,
                  Icons.alt_route,
                  "Road",
                  "Road Department",
                  Colors.orange,
                ),
                _squareDepartmentButton(
                  context,
                  Icons.water_drop,
                  "Water",
                  "Water Department",
                  Colors.blue,
                ),
                _squareDepartmentButton(
                  context,
                  Icons.electric_bolt,
                  "Electric",
                  "Electricity Department",
                  Colors.amber,
                ),
                _squareDepartmentButton(
                  context,
                  Icons.cleaning_services,
                  "Clean",
                  "Sanitation Department",
                  Colors.green,
                ),
              ],
            ),
          ),

          const Divider(),

          /// ISSUE LIST (MIDDLE)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: issueService.getAdminIssues(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No issues found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final issue = snapshot.data!.docs[index];
                    final data = issue.data() as Map<String, dynamic>;

                    final status = data['status'];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// TITLE
                            Text(
                              data['title'] ?? 'Untitled',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// DESCRIPTION
                            Text(data['description'] ?? ''),

                            const SizedBox(height: 6),

                            Text('Type: ${data['issueType'] ?? 'N/A'}'),

                            const SizedBox(height: 8),

                            /// STATUS BADGE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            /// ASSIGNED DEPARTMENT
                            if (data['assignedTo'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.apartment,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Assigned to: ${data['assignedTo']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => IssueDetailsScreen(
                                        issueId: issue.id,
                                        issueData: data,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View & Verify',
                                  style: TextStyle(color: Colors.white),
                                ),
                                
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// BOTTOM ADMIN TOOLS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _squareAdminButton(
                  context,
                  Icons.analytics,
                  "Analytics",
                  const AdminAnalyticsScreen(),
                ),
                _squareAdminButton(
                  context,
                  Icons.bar_chart,
                  "Performance",
                  const DepartmentPerformanceScreen(),
                ),
                _squareAdminButton(
                  context,
                  Icons.schedule,
                  "Delayed",
                  const DelayedIssuesScreen(),
                ),
                _squareAdminButton(
                  context,
                  Icons.people,
                  "Users",
                  const UserManagementScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TOP DEPARTMENT BUTTON
  Widget _squareDepartmentButton(
    BuildContext context,
    IconData icon,
    String label,
    String department,
    Color color,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DepartmentDashboard(department: department),
              ),
            );
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// BOTTOM ADMIN BUTTON
  Widget _squareAdminButton(
    BuildContext context,
    IconData icon,
    String label,
    Widget screen,
  ) {
    const primaryColor = Color(0xFF2563EB);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
