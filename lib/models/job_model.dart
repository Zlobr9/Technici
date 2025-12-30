import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String status;
  final String address;
  final DateTime dueDate;
  final List<String> imageUrls;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.address,
    required this.dueDate,
    this.imageUrls = const [],
  });

  // Factory constructor to create a Job from a Firestore document
  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'New',
      address: data['address'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  // Method to convert a Job to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'address': address,
      'dueDate': Timestamp.fromDate(dueDate),
      'imageUrls': imageUrls,
    };
  }
}
