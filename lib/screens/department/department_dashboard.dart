import 'package:civiclink/screens/auth/login_screen.dart';
import 'package:civiclink/screens/department/department_analytics_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pending_issues_screen.dart';
import 'field_visit_issues_screen.dart';
import 'in_progress_issues_screen.dart';
import 'resolved_issues_screen.dart';

class DepartmentDashboard extends StatelessWidget {
  final String department;

  const DepartmentDashboard({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          backgroundColor: primaryColor,
          centerTitle: true,

          title: Text(
            '$department Dashboard',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          actions: [
            /// ANALYTICS BUTTON
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              tooltip: 'Analytics',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DepartmentAnalyticsScreen(department: department),
                  ),
                );
              },
            ),

            /// LOGOUT
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],

          /// TAB BAR
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions, color: Colors.white),
                text: 'Pending',
              ),
              Tab(
                icon: Icon(Icons.event, color: Colors.white),
                text: 'Field Visit',
              ),
              Tab(
                icon: Icon(Icons.build, color: Colors.white),
                text: 'In Progress',
              ),
              Tab(
                icon: Icon(Icons.check_circle, color: Colors.white),
                text: 'Resolved',
              ),
            ],
          ),
        ),

        /// TAB CONTENT
        body: TabBarView(
          children: [
            PendingIssuesScreen(department: department),
            FieldVisitIssuesScreen(department: department),
            InProgressIssuesScreen(department: department),
            ResolvedIssuesScreen(department: department),
          ],
        ),
      ),
    );
  }
}
