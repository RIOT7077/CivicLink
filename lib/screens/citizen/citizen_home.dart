import 'package:civiclink/screens/citizen/profile_screen.dart';
import 'package:civiclink/screens/citizen/public_issues_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'report_issue_screen.dart';
import 'my_issues_screen.dart';
import '../auth/login_screen.dart';

class CitizenHome extends StatelessWidget {
  const CitizenHome({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget dashboardButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8FAFC);
    const primaryColor = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Citizen Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What would you like to do today?",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ),

              const SizedBox(height: 25),

              dashboardButton(
                context: context,
                icon: Icons.report_problem_outlined,
                title: 'Report New Issue',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportIssueScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              dashboardButton(
                context: context,
                icon: Icons.assignment_outlined,
                title: 'View My Submitted Issues',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyIssuesScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              dashboardButton(
                context: context,
                icon: Icons.campaign_outlined,
                title: 'Community Announcements',
                onTap: () {
                  Navigator.pushNamed(context, '/announcements');
                },
              ),

              const SizedBox(height: 12),

              dashboardButton(
                context: context,
                icon: Icons.public_outlined,
                title: 'View Public Issues',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PublicIssuesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              dashboardButton(
                context: context,
                icon: Icons.person_outline,
                title: 'My Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CitizenProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
