import 'package:flutter/material.dart';

class IssuePostCard extends StatelessWidget {
  final String issueId;
  final String imageUrl;
  final String userName;
  final String issueType;
  final String description;
  final int upvoteCount;
  final String priority;
  final VoidCallback onUpvote;
  final String status;


  const IssuePostCard({
    super.key,
    required this.issueId,
    required this.imageUrl,
    required this.userName,
    required this.issueType,
    required this.description,
    required this.status, 
    required this.priority,
    required this.upvoteCount,
    required this.onUpvote,
  });

  // 🔥 Priority → Color mapping
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 HEADER (Username + Type + Priority)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      label: Text(issueType),
                      backgroundColor: Colors.blue.shade50,
                    ),
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(
                        priority,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getPriorityColor(priority),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 ISSUE IMAGE (Safe)
          AspectRatio(
            aspectRatio: 1,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
          ),

          // 🔹 DESCRIPTION
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(description, style: const TextStyle(fontSize: 14)),
          ),

          // 🔹 ACTIONS (Upvote)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
               IconButton(
                  icon: Icon(
                    Icons.thumb_up_alt_outlined,
                    color: status == 'Resolved' ? Colors.grey : Colors.blue,
                  ),
                  onPressed: status == 'Resolved' ? null : onUpvote,
                ),

                Text(
                  '$upvoteCount Upvotes',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
