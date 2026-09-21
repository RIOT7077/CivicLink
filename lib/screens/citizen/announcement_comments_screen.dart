import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/comment_service.dart';

class AnnouncementCommentsScreen extends StatelessWidget {
  final String announcementId;
  final String userRole;

  AnnouncementCommentsScreen({
    super.key,
    required this.announcementId,
    required this.userRole,
  });

  final _commentController = TextEditingController();
  final CommentService service = CommentService();

  Color _roleColor(String role) {
    if (role == "admin") return Colors.red;
    if (role == "department") return Colors.orange;
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);
    const textPrimary = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// COMMENTS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.getComments(announcementId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final role = data['userRole'] ?? 'citizen';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// USER ICON
                            CircleAvatar(
                              backgroundColor: _roleColor(role),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// COMMENT CONTENT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        data['userName'] ?? 'Unknown User',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _roleColor(role),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          role,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  Text(data['text']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          /// COMMENT INPUT BOX
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// SEND BUTTON
                CircleAvatar(
                  backgroundColor: primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) return;

                      await service.addComment(
                        announcementId: announcementId,
                        text: _commentController.text.trim(),
                        userRole: userRole,
                      );

                      _commentController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
