// Home Page
import 'dart:developer';
import 'package:doctai/components/nearby_hospital_card.dart';
import 'package:doctai/controllers/language_controller.dart';
import 'package:doctai/components/quick_topic_detail_page.dart';
import 'package:doctai/models/hospital_model.dart';
import 'package:doctai/view/agents/audio_app_manager_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_magic_button/flutter_magic_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> quickTopics = [
    {
      'title': 'Lung Infection',
      'subtitle':
          'Caused by various pathogens\nsuch as viruses, bacteria, fungi,\nor parasites.',
      'details': '''
**What is a Lung Infection?**
A lung infection can affect your ability to breathe and lead to conditions like pneumonia, bronchitis, and tuberculosis.

**Causes:**
- Viruses: Influenza, RSV, COVID-19
- Bacteria: Streptococcus pneumoniae
- Fungi: Aspergillus
- Parasites: Rare in most regions

**Symptoms:**
- Cough with phlegm
- Chest pain
- Shortness of breath
- Fever or chills

**Treatment:**
- Rest, fluids, antibiotics or antivirals
- Seek urgent care if breathing becomes difficult
''',
      'icon': Icons.favorite,
      'color': Color(0xFFFF6B6B),
    },
    {
      'title': 'Safety In Corona',
      'subtitle':
          'Ensure you and those eligible in\nyour community are vaccinated\nagainst COVID-19.',
      'details': '''
**Why COVID-19 Safety Still Matters**

**Key Safety Practices:**
- Get vaccinated and stay updated on boosters
- Wear masks in crowded indoor areas
- Maintain good hand hygiene
- Avoid close contact when sick

**Benefits of Vaccination:**
- Reduces risk of severe illness
- Protects vulnerable populations
- Helps stop virus transmission

**Remember:** COVID-19 variants still circulate. Stay cautious and informed.
''',
      'icon': Icons.shield,
      'color': Color(0xFF4ECDC4),
    },
  ];
  final List<HospitalModel> realHospitals = [
    HospitalModel(
      name: 'Aga Khan University Hospital',
      address: 'Stadium Road, Karachi, Sindh',
      distanceKm: 5.0,
      rating: 4.7,
      openingHours: '9 AM–9 PM (Emergency 24/7)',
      imageUrl: 'https://example.com/aku-hospital.jpg',
      latitude: 24.891975,
      longitude: 67.072861,
    ), // Coordinates verified :contentReference[oaicite:1]{index=1}

    HospitalModel(
      name: 'Liaquat National Hospital',
      address: 'Stadium Road, Karachi, Sindh',
      distanceKm: 4.0,
      rating: 4.4,
      openingHours: '24/7',
      imageUrl: 'https://example.com/liaquat.jpg',
      latitude: 24.893379,
      longitude: 67.028061,
    ), // Verified :contentReference[oaicite:2]{index=2}

    HospitalModel(
      name: 'Jinnah Postgraduate Medical Centre',
      address: 'Rafiqui Shaheed Road, Karachi Cantonment',
      distanceKm: 6.0,
      rating: 4.2,
      openingHours: '24/7',
      imageUrl: 'https://example.com/jpmc.jpg',
      latitude: 24.852475,
      longitude: 67.045914,
    ), // Verified :contentReference[oaicite:3]{index=3}

    HospitalModel(
      name: 'Civil Hospital Karachi',
      address: 'Mission Road, Karachi, Sindh',
      distanceKm: 7.0,
      rating: 4.1,
      openingHours: '24/7',
      imageUrl: 'https://example.com/civilhos.jpg',
      latitude: 24.8645,
      longitude: 67.0099,
    ), // Coordinates approximate from map

    HospitalModel(
      name: 'Ziauddin Hospital (Clifton)',
      address: 'Shahrah‑e‑Ghalib, Clifton, Karachi',
      distanceKm: 8.0,
      rating: 4.3,
      openingHours: '24/7',
      imageUrl: 'https://example.com/ziauddin.jpg',
      latitude: 24.8198,
      longitude: 67.0424,
    ), // approximate geo-coordinates

    HospitalModel(
      name: 'Burhani Hospital',
      address: 'Faiz Muhammad Fateh Ali Rd, New Chali, Karachi',
      distanceKm: 9.0,
      rating: 4.0,
      openingHours: '24/7',
      imageUrl: 'https://example.com/burhani.jpg',
      latitude: 24.8892,
      longitude: 67.0425,
    ),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = context.read<LanguageProvider>().languageCode;
    log(langCode);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF357ABD),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF4A90E2)),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Welcome',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 28),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Unlock Section
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlocking AI\'s Potential for\nHealthier Futures',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 60,
                                child: Expanded(
                                  child: MagicButton(
                                    label: "Get Help",
                                    icon: Icons.health_and_safety,
                                    buttonColor: const Color(0xFF1E1637),
                                    animatingColors: const [
                                      Color(0xFF00FFFF),
                                      Color(0xFF00BFFF),
                                      Color(0xFF1E90FF),
                                    ],
                                    borderRadius: BorderRadius.circular(12),
                                    animationDuration: Duration(seconds: 2),
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    iconColor: Colors.white,
                                    iconSize: 24,
                                    onPress: () {
                                      // Handle action
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MedAIHelpAssistantView(
                                              title: '',
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        // Quick Topics
                        Text(
                          'Quick Topics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 15),
                        ...quickTopics.map((topic) => InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuickTopicDetailPage(
                                      title: topic['title'],
                                      details: topic['details'],
                                      color: topic['color'],
                                      icon: topic['icon'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: topic['color'].withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        topic['color'].withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: topic['color'],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        topic['icon'],
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            topic['title'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            topic['subtitle'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios,
                                        color: Colors.grey, size: 16),
                                  ],
                                ),
                              ),
                            )),
                        SizedBox(height: 30),
                        // Recent Appointments
                        Text(
                          'Recent Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 15),
                        for (final hospital in realHospitals)
                          NearbyHospitalCard(hospital: hospital),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
