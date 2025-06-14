// Healthcare-specific tools for MedAI
import 'package:doctai/controllers/live_ai_calling_agent_controller.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Tool declarations for healthcare functions
final FunctionDeclaration symptomCheckerTool = FunctionDeclaration(
  'checkSymptoms',
  'Analyze user symptoms and provide basic medical guidance',
  parameters: {
    'symptoms': Schema.array(
      description: 'List of symptoms described by the user',
      items: Schema.string(),
    ),
    'severity': Schema.enumString(
      description: 'Severity level: mild, moderate, severe, emergency',
      enumValues: ['mild', 'moderate', 'severe', 'emergency'],
    ),
    'duration': Schema.string(
      description: 'How long symptoms have been present',
    ),
  },
);

final FunctionDeclaration nearbyHealthcareTool = FunctionDeclaration(
  'findNearbyHealthcare',
  'Find nearby hospitals, clinics, and pharmacies',
  parameters: {
    'serviceType': Schema.enumString(
      description: 'Type of healthcare service needed',
      enumValues: ['hospital', 'clinic', 'pharmacy', 'emergency', 'blood_bank'],
    ),
    'urgency': Schema.enumString(
      description: 'Urgency level to filter appropriate facilities',
      enumValues: ['routine', 'urgent', 'emergency'],
    ),
    'radius': Schema.number(
      description: 'Search radius in kilometers (default: 10)',
    ),
  },
);

final FunctionDeclaration medicationReminderTool = FunctionDeclaration(
  'setMedicationReminder',
  'Set reminders for medications and appointments',
  parameters: {
    'medicationName': Schema.string(
      description: 'Name of the medication',
    ),
    'dosage': Schema.string(
      description: 'Dosage information (e.g., "500mg", "2 tablets")',
    ),
    'frequency': Schema.string(
      description: 'How often to take (e.g., "twice daily", "every 8 hours")',
    ),
    'reminderTimes': Schema.array(
      description: 'Specific times for reminders (HH:MM format)',
      items: Schema.string(),
    ),
    'startDate': Schema.string(
      description: 'Start date for medication (YYYY-MM-DD)',
    ),
    'duration': Schema.string(
      description: 'Duration of treatment (e.g., "7 days", "2 weeks")',
    ),
  },
);

final FunctionDeclaration pillIdentifierTool = FunctionDeclaration(
  'identifyPill',
  'Identify pills from description or image analysis',
  parameters: {
    'description': Schema.string(
      description: 'Physical description of the pill (color, shape, markings)',
    ),
    'imprint': Schema.string(
      description: 'Any text or numbers on the pill',
    ),
    'color': Schema.string(
      description: 'Primary color of the pill',
    ),
    'shape': Schema.enumString(
      description: 'Shape of the pill',
      enumValues: ['round', 'oval', 'square', 'capsule', 'diamond', 'triangle'],
    ),
    'size': Schema.string(
      description: 'Approximate size (small, medium, large)',
    ),
  },
);

final FunctionDeclaration firstAidGuidanceTool = FunctionDeclaration(
  'provideFirstAid',
  'Provide step-by-step first aid guidance for emergencies',
  parameters: {
    'emergency': Schema.enumString(
      description: 'Type of emergency or injury',
      enumValues: [
        'burn',
        'cut',
        'nosebleed',
        'choking',
        'fracture',
        'allergic_reaction',
        'chest_pain',
        'breathing_difficulty',
        'unconscious',
        'poisoning'
      ],
    ),
    'severity': Schema.enumString(
      description: 'Severity of the emergency',
      enumValues: ['minor', 'moderate', 'severe', 'life_threatening'],
    ),
    'patientAge': Schema.enumString(
      description: 'Age group of the patient',
      enumValues: ['infant', 'child', 'adult', 'elderly'],
    ),
  },
);

final FunctionDeclaration emergencyContactsTool = FunctionDeclaration(
  'getEmergencyContacts',
  'Get local emergency numbers and contacts',
  parameters: {
    'location': Schema.string(
      description: 'Current location or city',
    ),
    'emergencyType': Schema.enumString(
      description: 'Type of emergency service needed',
      enumValues: [
        'ambulance',
        'police',
        'fire',
        'poison_control',
        'mental_health'
      ],
    ),
  },
);

final FunctionDeclaration healthEducationTool = FunctionDeclaration(
  'getHealthEducation',
  'Provide health education and preventive care information',
  parameters: {
    'topic': Schema.enumString(
      description: 'Health topic to learn about',
      enumValues: [
        'nutrition',
        'exercise',
        'vaccination',
        'pregnancy',
        'child_health',
        'mental_health',
        'hygiene',
        'disease_prevention'
      ],
    ),
    'ageGroup': Schema.enumString(
      description: 'Target age group',
      enumValues: ['infant', 'child', 'adolescent', 'adult', 'elderly'],
    ),
    'language': Schema.enumString(
      description: 'Preferred language for information',
      enumValues: ['english', 'urdu', 'punjabi', 'sindhi'],
    ),
  },
);

// Function implementations

void checkSymptomsCall(BuildContext context, FunctionCall functionCall) async {
  final args = functionCall.args;
  final symptomsRaw = args['symptoms'];
  final List<String> symptoms =
      symptomsRaw is List ? symptomsRaw.cast<String>() : <String>[];
  final severity = args['severity'] ?? 'mild';
  final duration = args['duration'] ?? 'recent';

  // Store symptom data in app state
  final appState =
      Provider.of<LiveAICallingAgentController>(context, listen: false);
  appState.setSymptomData({
    'symptoms': symptoms,
    'severity': severity,
    'duration': duration,
    'timestamp': DateTime.now().toIso8601String(),
  });

  print(
      'Symptom check requested: ${symptoms.join(", ")} - Severity: $severity');
}

void findNearbyHealthcareCall(
    BuildContext context, FunctionCall functionCall) async {
  final args = functionCall.args;
  final serviceType = args['serviceType'] ?? 'clinic';
  final urgency = args['urgency'] ?? 'routine';
  final radius = args['radius'] ?? 10.0;

  final appState =
      Provider.of<LiveAICallingAgentController>(context, listen: false);
  appState.setHealthcareSearch({
    'serviceType': serviceType,
    'urgency': urgency,
    'radius': radius,
    'timestamp': DateTime.now().toIso8601String(),
  });

  print(
      'Healthcare search: $serviceType within ${radius}km - Urgency: $urgency');
}

void setMedicationReminderCall(
    BuildContext context, FunctionCall functionCall) async {
  final args = functionCall.args;
  final medicationName = args['medicationName'] ?? '';
  final dosage = args['dosage'] ?? '';
  final frequency = args['frequency'] ?? '';
  final reminderTimesRaw = args['reminderTimes'];
  final List<String> reminderTimes =
      reminderTimesRaw is List ? reminderTimesRaw.cast<String>() : <String>[];
  final startDate = args['startDate'] ?? '';
  final duration = args['duration'] ?? '';

  final appState =
      Provider.of<LiveAICallingAgentController>(context, listen: false);
  appState.addMedicationReminder({
    'medicationName': medicationName,
    'dosage': dosage,
    'frequency': frequency,
    'reminderTimes': reminderTimes,
    'startDate': startDate,
    'duration': duration,
    'isActive': true,
    'timestamp': DateTime.now().toIso8601String(),
  });

  print('Medication reminder set: $medicationName - $dosage $frequency');
}

void identifyPillCall(BuildContext context, FunctionCall functionCall) async {
  final args = functionCall.args;
  final description = args['description'] ?? '';
  final imprint = args['imprint'] ?? '';
  final color = args['color'] ?? '';
  final shape = args['shape'] ?? '';
  final size = args['size'] ?? '';

  final appState =
      Provider.of<LiveAICallingAgentController>(context, listen: false);
  appState.setPillIdentificationData({
    'description': description,
    'imprint': imprint,
    'color': color,
    'shape': shape,
    'size': size,
    'timestamp': DateTime.now().toIso8601String(),
  });

  print(
      'Pill identification requested: $color $shape pill with imprint "$imprint"');
}

void provideFirstAidCall(
    BuildContext context, FunctionCall functionCall) async {
  final args = functionCall.args;
  final emergency = args['emergency'] ?? '';
  final severity = args['severity'] ?? 'minor';
  final patientAge = args['patientAge'] ?? 'adult';

  final appState =
      Provider.of<LiveAICallingAgentController>(context, listen: false);
  appState.setFirstAidRequest({
    'emergency': emergency,
    'severity': severity,
    'patientAge': patientAge,
    'timestamp': DateTime.now().toIso8601String(),
  });

  print('First aid guidance requested: $emergency ($severity) for $patientAge');
}

void getEmergencyContactsCall(
    BuildContext context, FunctionCall functionCall) async {
  final args = functionCall.args;
  final location = args['location'] ?? '';
  final emergencyType = args['emergencyType'] ?? 'ambulance';

  final appState =
      Provider.of<LiveAICallingAgentController>(context, listen: false);
  appState.setEmergencyContactRequest({
    'location': location,
    'emergencyType': emergencyType,
    'timestamp': DateTime.now().toIso8601String(),
  });

  print('Emergency contacts requested: $emergencyType in $location');
}

void getHealthEducationCall(
    BuildContext context, FunctionCall functionCall) async {
  final args = functionCall.args;
  final topic = args['topic'] ?? '';
  final ageGroup = args['ageGroup'] ?? 'adult';
  final language = args['language'] ?? 'english';

  final appState =
      Provider.of<LiveAICallingAgentController>(context, listen: false);
  appState.setHealthEducationRequest({
    'topic': topic,
    'ageGroup': ageGroup,
    'language': language,
    'timestamp': DateTime.now().toIso8601String(),
  });

  print('Health education requested: $topic for $ageGroup in $language');
}
