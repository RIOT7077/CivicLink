import 'package:civiclink/screens/splash_screen.dart';
import 'package:flutter/material.dart';

import 'screens/citizen/community_announcements_screen.dart';
import 'screens/admins/announcements_dashboard.dart';
import 'screens/admins/create_announcement_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SplashScreen(),  // role-based navigation handled after login
      routes: {
        // Community Announcements
        '/announcements': (context) => const CommunityAnnouncementsScreen(),

        // Admin routes
        '/admin-announcements': (context) => const AnnouncementsDashboard(),
        '/create-announcement': (context) => const CreateAnnouncementScreen(),
      },
    );
  }
}
