import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String title;
  final String description;
  final String issueType;
  final String status;
  final String submittedBy;
  final Timestamp createdAt;
  final double latitude;
  final double longitude;
  final String locationUrl;
  final String? imageUrl;
  final String? resolvedImageUrl;
  final String reportedByName;

  Issue({
    required this.title,
    required this.description,
    required this.issueType,
    required this.status,
    required this.submittedBy,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.reportedByName,
    required this.locationUrl,
    required this.imageUrl,
    this.resolvedImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'issueType': issueType,
      'status': status,
      'submittedBy': submittedBy,
      'createdAt': createdAt,
      'reportedByName': reportedByName,
      'latitude': latitude,
      'longitude': longitude,
      'locationUrl': locationUrl,
      'imageUrl': imageUrl,
      'resolvedImageUrl': resolvedImageUrl,
    };
  }

  factory Issue.fromMap(Map<String, dynamic> data) {
    return Issue(
      title: data['title'],
      description: data['description'],
      issueType: data['issueType'],
      status: data['status'],
      submittedBy: data['submittedBy'],
      reportedByName: data['reportedByName'] ?? 'Citizen',
      createdAt: data['createdAt'],
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      locationUrl: data['locationUrl'],
      imageUrl: data['imageUrl'],
    );
  }
}
