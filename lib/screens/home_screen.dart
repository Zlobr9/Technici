import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/firestore_service.dart';
import '../models/job_model.dart';
import '../models/contact_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Dashboard',
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is a summary of your activity.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          StreamProvider<List<Job>>.value(
            value: firestoreService.getJobs(),
            initialData: const [],
            child: Consumer<List<Job>>(
              builder: (context, jobs, _) {
                return _buildSummaryCard(
                  context,
                  title: 'Active Jobs',
                  count: jobs.where((j) => j.status != 'Completed').length.toString(),
                  icon: Icons.work_outline,
                  color: theme.colorScheme.primary,
                  onTap: () {},
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          StreamProvider<List<Contact>>.value(
            value: firestoreService.getContacts(),
            initialData: const [],
            child: Consumer<List<Contact>>(
              builder: (context, contacts, _) {
                return _buildSummaryCard(
                  context,
                  title: 'Total Contacts',
                  count: contacts.length.toString(),
                  icon: Icons.contacts_outlined,
                  color: theme.colorScheme.secondary,
                  onTap: () {},
                );
              },
            ),
          ),
          const SizedBox(height: 24),
           Text(
            'Upcoming Deadlines',
             style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
           const SizedBox(height: 16),
          _buildUpcomingJobs(firestoreService),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required String count, required IconData icon, required Color color, required VoidCallback onTap,}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
                  Text(title, style: theme.textTheme.titleMedium),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildUpcomingJobs(FirestoreService firestoreService) {
    return StreamBuilder<List<Job>>(
      stream: firestoreService.getJobs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No upcoming jobs.'));
        }

        final upcomingJobs = snapshot.data!
            .where((job) => job.dueDate.isAfter(DateTime.now()))
            .toList();

         upcomingJobs.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingJobs.length > 5 ? 5 : upcomingJobs.length,
          itemBuilder: (context, index) {
            final job = upcomingJobs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(DateFormat.d().format(job.dueDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(job.title),
                 subtitle: Text('Due: ${DateFormat.yMMMd().format(job.dueDate)}'),
                 trailing: const Icon(Icons.chevron_right),
                 onTap: () { /* Navigate to job details */ },
              ),
            );
          },
        );
      },
    );
  }
}
