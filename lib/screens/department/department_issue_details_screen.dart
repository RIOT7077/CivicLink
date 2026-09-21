import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/issue_service.dart';
import '../../core/services/cloudinary_service.dart';

class DepartmentIssueDetailsScreen extends StatefulWidget {
  final String issueId;
  final Map<String, dynamic> issueData;

  const DepartmentIssueDetailsScreen({
    super.key,
    required this.issueId,
    required this.issueData,
  });

  @override
  State<DepartmentIssueDetailsScreen> createState() =>
      _DepartmentIssueDetailsScreenState();
}

class _DepartmentIssueDetailsScreenState
    extends State<DepartmentIssueDetailsScreen> {
  final remarkController = TextEditingController();
  File? resolvedImage;
  bool isSubmitting = false;

  static const List<String> workflow = [
    'Assigned',
    'Field Visit Scheduled',
    'In Progress',
    'Resolved',
  ];

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickResolvedImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickResolvedImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickResolvedImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);

    if (picked != null) {
      setState(() {
        resolvedImage = File(picked.path);
      });
    }
  }

  Future<void> _markResolved() async {
    if (resolvedImage == null && remarkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add resolution image or remark')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String? imageUrl;

      if (resolvedImage != null) {
        imageUrl = await CloudinaryService().uploadImage(resolvedImage!);
      }

      await IssueService().resolveIssueWithImage(
        issueId: widget.issueId,
        status: 'Resolved',
        remark: remarkController.text.trim(),
        resolvedImageUrl: imageUrl,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFFF8FAFC);
    const textPrimary = Color(0xFF1E293B);

    final data = widget.issueData;
    final currentStatus = data['status'];

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Issue Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ISSUE INFO CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(14),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      data['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(data['description'] ?? ''),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Chip(label: Text(currentStatus)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// BEFORE IMAGE
            if (data['imageUrl'] != null &&
                data['imageUrl'].toString().isNotEmpty)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Before (Reported Issue)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(data['imageUrl']),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// AFTER IMAGE
            if (data['resolvedImageUrl'] != null &&
                data['resolvedImageUrl'].toString().isNotEmpty)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'After (Resolution Proof)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(data['resolvedImageUrl']),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// STATUS UPDATE BUTTONS
            if (currentStatus != 'Resolved')
              ...workflow.map((status) {
                final isNext =
                    workflow.indexOf(status) ==
                    workflow.indexOf(currentStatus) + 1;

                if (!isNext || status == 'Resolved') {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),

                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await IssueService().updateDepartmentIssueStatus(
                          widget.issueId,
                          status,
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      child: Text('Mark as "$status"'),
                    ),
                  ),
                );
              }),

            /// RESOLUTION SECTION
            if (currentStatus == 'In Progress') ...[
              const SizedBox(height: 10),

              Card(
                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(14),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Resolution Evidence',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: remarkController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Resolution Remarks',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: _showImageSourcePicker,
                        icon: const Icon(Icons.upload),
                        label: const Text('Add Resolution Proof'),
                      ),

                      if (resolvedImage != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            resolvedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _markResolved,
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Mark Issue as Resolved'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            /// STATUS TIMELINE
            const Text(
              'Status Timeline',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            ...(data['statusHistory'] ?? []).map<Widget>((entry) {
              final ts = entry['timestamp'] as Timestamp?;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(entry['status']),
                  subtitle: Text(
                    ts != null ? ts.toDate().toString() : 'Unknown time',
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
