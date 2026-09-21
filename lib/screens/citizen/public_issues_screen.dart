import 'package:civiclink/widgets/issue_post_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/issue_service.dart';

class PublicIssuesScreen extends StatelessWidget {
  const PublicIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final IssueService issueService = IssueService();

    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Public Issues',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: issueService.getAllPublicIssues(),
        builder: (context, snapshot) {
          /// ERROR STATE
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          /// LOADING STATE
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// EMPTY STATE
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No issues reported yet',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          /// ISSUE FEED
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: IssuePostCard(
                  issueId: doc.id,
                  imageUrl: data['imageUrl'] ?? '',
                  userName: data['reportedByName'] ?? 'Citizen',
                  issueType: data['issueType'] ?? 'Unknown',
                  description: data['description'] ?? '',
                  upvoteCount: data['upvoteCount'] ?? 0,
                  priority: data['priority'] is String
                      ? data['priority']
                      : issueService.calculatePriority(
                          data['upvoteCount'] ?? 0,
                        ),
                  status: data['status'] ?? 'Submitted',
                  onUpvote: () {
                    issueService.toggleUpvote(doc.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
