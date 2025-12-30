import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';

import '../models/job_model.dart';
import '../services/firestore_service.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _jobLocation;
  StreamSubscription<Job>? _jobSubscription;
  String? _lastGeocodedAddress;

  @override
  void initState() {
    super.initState();
    _jobSubscription = _firestoreService.getJob(widget.jobId).listen((job) {
      if (job.address.isNotEmpty && job.address != _lastGeocodedAddress) {
        _geocodeAddress(job.address);
      }
    });
  }

  @override
  void dispose() {
    _jobSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _geocodeAddress(String address) async {
    if (address == _lastGeocodedAddress) return;

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty && mounted) {
        final location = locations.first;
        setState(() {
          _lastGeocodedAddress = address;
          _jobLocation = LatLng(location.latitude, location.longitude);
          _markers = {
            Marker(
              markerId: MarkerId(widget.jobId),
              position: _jobLocation!,
              infoWindow: const InfoWindow(title: 'Job Location'),
            ),
          };
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_jobLocation!, 15),
        );
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      if (mounted) {
        setState(() {
          _lastGeocodedAddress = address;
        });
      }
    }
  }

  void _openPhotoGallery(
    BuildContext context,
    final List<String> imageUrls,
    final int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
          body: PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder<Job>(
        stream: _firestoreService.getJob(widget.jobId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _jobLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Job not found.'));
          }

          final job = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: _jobLocation != null ? 250.0 : 0,
                floating: false,
                pinned: true,
                flexibleSpace: _jobLocation != null ? FlexibleSpaceBar(
                  background: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _jobLocation!,
                      zoom: 15.0,
                    ),
                    markers: _markers,
                    zoomControlsEnabled: false,
                  ),
                ) : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                           Chip(
                            label: Text(job.status),
                            backgroundColor: _getStatusColor(context, job.status),
                            labelStyle: TextStyle(
                              color: _getStatusTextColor(context, job.status),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Due: ${DateFormat.yMMMd().format(job.dueDate)}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                       const SizedBox(height: 24),
                      _buildDetailRow(
                        context,
                        Icons.description_outlined,
                        'Description',
                        job.description,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        Icons.location_on_outlined,
                        'Address',
                        job.address,
                      ),
                       const SizedBox(height: 24),
                      if (job.imageUrls.isNotEmpty)
                        _buildPhotoGallery(context, job.imageUrls),
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

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(BuildContext context, List<String> imageUrls) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo Gallery', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openPhotoGallery(context, imageUrls, index),
                child: Hero(
                  tag: imageUrls[index],
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imageUrls[index],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.error, size: 40, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
        return colorScheme.onSurface;
    }
  }
}
