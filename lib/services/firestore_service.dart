import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/job_model.dart';
import '../models/contact_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ~~~~~~~~~~ Job Methods ~~~~~~~~~~

  Stream<List<Job>> getJobs() {
    return _db
        .collection('jobs')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList(),
        );
  }

  Stream<Job> getJob(String jobId) {
    return _db
        .collection('jobs')
        .doc(jobId)
        .snapshots()
        .map((snapshot) => Job.fromFirestore(snapshot));
  }

  Future<void> addJob(Map<String, dynamic> jobData) {
    return _db.collection('jobs').add(jobData);
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> jobData) {
    return _db.collection('jobs').doc(jobId).update(jobData);
  }

  Future<String> uploadImage(XFile image) async {
    // Create a unique file name
    String fileName =
        'jobs/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    Reference storageRef = _storage.ref().child(fileName);

    // Upload the file
    await storageRef.putFile(File(image.path));

    // Get the download URL
    String downloadURL = await storageRef.getDownloadURL();
    return downloadURL;
  }

  Future<void> addDummyJobs() async {
    final jobsCollection = _db.collection('jobs');
    final snapshot = await jobsCollection.limit(1).get();
    if (snapshot.docs.isEmpty) {
      debugPrint("Adding dummy jobs...");
      final today = DateTime.now();
      final dummyJobs = [
        Job(
          id: '',
          title: 'Oprava serveru',
          description: 'Výměna vadného disku v serveru DC01.',
          status: 'New',
          address: 'Hlavní 1, Praha',
          dueDate: today.add(const Duration(days: 1)),
        ),
        Job(
          id: '',
          title: 'Instalace tiskárny',
          description: 'Nová tiskárna pro účetní oddělení.',
          status: 'In Progress',
          address: 'Vedlejší 2, Brno',
          dueDate: today.add(const Duration(days: 3)),
        ),
        Job(
          id: '',
          title: 'Výměna monitoru',
          description: 'Uživatel si stěžuje na blikající monitor.',
          status: 'Completed',
          address: 'Zadní 3, Ostrava',
          dueDate: today.subtract(const Duration(days: 2)),
        ),
      ];
      for (var job in dummyJobs) {
        await jobsCollection.add(job.toMap());
      }
    }
  }

  // ~~~~~~~~~~ Contact Methods ~~~~~~~~~~

  Stream<List<Contact>> getContacts() {
    return _db
        .collection('contacts')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList(),
        );
  }

  Stream<Contact> getContact(String contactId) {
    return _db
        .collection('contacts')
        .doc(contactId)
        .snapshots()
        .map((snapshot) => Contact.fromFirestore(snapshot));
  }

  Future<DocumentReference> addContact(Map<String, dynamic> contactData) {
    return _db.collection('contacts').add(contactData);
  }

  Future<void> updateContact(
    String contactId,
    Map<String, dynamic> contactData,
  ) {
    return _db.collection('contacts').doc(contactId).update(contactData);
  }

  Future<void> deleteContact(String contactId) {
    return _db.collection('contacts').doc(contactId).delete();
  }

  Future<void> addDummyContacts() async {
    final contactsCollection = _db.collection('contacts');
    final snapshot = await contactsCollection.limit(1).get();
    if (snapshot.docs.isEmpty) {
      debugPrint("Adding dummy contacts...");
      final dummyContacts = [
        {
          'name': 'Alice Nováková',
          'email': 'alice@example.com',
          'phone': '123 456 789',
          'address': 'Technická 5, Praha',
        },
        {
          'name': 'Bob Svoboda',
          'email': 'bob@example.com',
          'phone': '987 654 321',
          'address': 'Moravská 10, Brno',
        },
      ];
      for (var contact in dummyContacts) {
        await contactsCollection.add(contact);
      }
    }
  }
}
