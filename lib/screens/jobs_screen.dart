import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'All', label: Text('All')),
                  ButtonSegment<String>(value: 'New', label: Text('New')),
                  ButtonSegment<String>(
                    value: 'In Progress',
                    label: Text('In Progress'),
                  ),
                  ButtonSegment<String>(
                    value: 'Completed',
                    label: Text('Completed'),
                  ),
                ],
                selected: {_selectedStatus},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedStatus = newSelection.first;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Job>>(
              stream: _firestoreService.getJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Chyba: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Žádné zakázky k zobrazení.'));
                }

                final jobs = _selectedStatus == 'All'
                    ? snapshot.data!
                    : snapshot.data!
                        .where((job) => job.status == _selectedStatus)
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 80,
                  ), // Add padding for FAB
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shadowColor: Colors.black.withAlpha(26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        title: Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            job.address,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        trailing: Chip(
                          label: Text(job.status),
                          backgroundColor: _getStatusColor(context, job.status),
                          labelStyle: TextStyle(
                            color: _getStatusTextColor(context, job.status),
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onTap: () {
                          context.go('/jobs/detail/${job.id}');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_job_fab',
        onPressed: () {
          context.go('/add-job');
        },
        tooltip: 'Přidat zakázku',
        icon: const Icon(Icons.add),
        label: const Text('Nová zakázka'),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'New':
        return colorScheme.primaryContainer;
      case 'In Progress':
        return colorScheme.secondaryContainer;
      case 'Completed':
        return colorScheme.tertiaryContainer;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getStatusTextColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'New':
        return colorScheme.onPrimaryContainer;
      case 'In Progress':
        return colorScheme.onSecondaryContainer;
      case 'Completed':
        return colorScheme.onTertiaryContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
