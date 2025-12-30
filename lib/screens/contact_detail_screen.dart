import 'package:flutter/material.dart';
import 'package:myapp/models/contact_model.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailScreen extends StatelessWidget {
  final String contactId;
  const ContactDetailScreen({super.key, required this.contactId});

 Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder<Contact>(
        stream: firestoreService.getContact(contactId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Contact not found.'));
          }

          final contact = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                 expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(contact.name, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                  background: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      contact.name.isNotEmpty ? contact.name[0] : '-',
                      style: TextStyle(
                        fontSize: 80,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailCard(context, 'Email', contact.email, Icons.email_outlined, () => _sendEmail(contact.email)),
                      const SizedBox(height: 16),
                      _buildDetailCard(context, 'Phone', contact.phone, Icons.phone_outlined, () => _makePhoneCall(contact.phone)),
                      const SizedBox(height: 16),
                      _buildDetailCard(context, 'Address', contact.address, Icons.location_on_outlined, null),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

   Widget _buildDetailCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback? onTap) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Icon(icon, color: theme.colorScheme.primary, size: 28),
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodyLarge),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
        onTap: onTap,
      ),
    );
  }
}
