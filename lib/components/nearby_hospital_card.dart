import 'dart:io';

import 'package:doctai/models/hospital_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyHospitalCard extends StatelessWidget {
  final HospitalModel hospital;

  const NearbyHospitalCard({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    // final uri = Uri.parse(
    //     'https://maps.google.com/?q=${hospital.latitude},${hospital.longitude}');
    Future<void> openMaps(double lat, double lng) async {
      Uri uri;
      if (Platform.isAndroid) {
        // Use Android’s geo URI scheme
        uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
      } else if (Platform.isIOS) {
        // Launch native Apple Maps
        uri = Uri.parse('maps:$lat,$lng?q=$lat,$lng');
      } else {
        // Fallback to Google Maps via browser for web/desktop
        uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $uri';
      }
    }

    return GestureDetector(
      onTap: () {
        openMaps(hospital.latitude, hospital.longitude);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Hospital image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hospital.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.local_hospital,
                        size: 40, color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Hospital details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hospital.address,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⭐ ${hospital.rating} · 🕒 ${hospital.openingHours}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Distance
              Column(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.blueAccent),
                  const SizedBox(height: 4),
                  Text('${hospital.distanceKm.toStringAsFixed(1)} km'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
