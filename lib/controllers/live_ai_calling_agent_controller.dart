import 'package:flutter/material.dart';

class LiveAICallingAgentController with ChangeNotifier {
  // Healthcare-specific state
  Map<String, dynamic>? _currentSymptomData;
  Map<String, dynamic>? _healthcareSearchData;
  final List<Map<String, dynamic>> _medicationReminders = [];
  Map<String, dynamic>? _pillIdentificationData;
  Map<String, dynamic>? _firstAidRequest;
  Map<String, dynamic>? _emergencyContactRequest;
  Map<String, dynamic>? _healthEducationRequest;
  final List<Map<String, dynamic>> _patientHistory = [];

  // User preferences
  String _preferredLanguage = 'english';
  String _userLocation = '';
  final Map<String, String> _emergencyContacts = {};
  bool _shareLocationForEmergency = false;

  // App settings
  bool _isEmergencyMode = false;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;

  // Getters
  Map<String, dynamic>? get currentSymptomData => _currentSymptomData;
  Map<String, dynamic>? get healthcareSearchData => _healthcareSearchData;
  List<Map<String, dynamic>> get medicationReminders => _medicationReminders;
  Map<String, dynamic>? get pillIdentificationData => _pillIdentificationData;
  Map<String, dynamic>? get firstAidRequest => _firstAidRequest;
  Map<String, dynamic>? get emergencyContactRequest => _emergencyContactRequest;
  Map<String, dynamic>? get healthEducationRequest => _healthEducationRequest;
  List<Map<String, dynamic>> get patientHistory => _patientHistory;

  String get preferredLanguage => _preferredLanguage;
  String get userLocation => _userLocation;
  Map<String, String> get emergencyContacts => _emergencyContacts;
  bool get shareLocationForEmergency => _shareLocationForEmergency;
  bool get isEmergencyMode => _isEmergencyMode;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  // Healthcare data setters
  void setSymptomData(Map<String, dynamic> data) {
    _currentSymptomData = data;
    _addToPatientHistory('symptom_check', data);
    notifyListeners();
  }

  void setHealthcareSearch(Map<String, dynamic> data) {
    _healthcareSearchData = data;
    notifyListeners();
  }

  void addMedicationReminder(Map<String, dynamic> reminder) {
    _medicationReminders.add(reminder);
    notifyListeners();
  }

  void updateMedicationReminder(int index, Map<String, dynamic> reminder) {
    if (index >= 0 && index < _medicationReminders.length) {
      _medicationReminders[index] = reminder;
      notifyListeners();
    }
  }

  void removeMedicationReminder(int index) {
    if (index >= 0 && index < _medicationReminders.length) {
      _medicationReminders.removeAt(index);
      notifyListeners();
    }
  }

  void setPillIdentificationData(Map<String, dynamic> data) {
    _pillIdentificationData = data;
    _addToPatientHistory('pill_identification', data);
    notifyListeners();
  }

  void setFirstAidRequest(Map<String, dynamic> data) {
    _firstAidRequest = data;
    _addToPatientHistory('first_aid', data);

    // Auto-enable emergency mode for severe cases
    if (data['severity'] == 'life_threatening' ||
        data['severity'] == 'severe') {
      setEmergencyMode(true);
    }

    notifyListeners();
  }

  void setEmergencyContactRequest(Map<String, dynamic> data) {
    _emergencyContactRequest = data;
    notifyListeners();
  }

  void setHealthEducationRequest(Map<String, dynamic> data) {
    _healthEducationRequest = data;
    notifyListeners();
  }

  // User preferences setters
  void setPreferredLanguage(String language) {
    _preferredLanguage = language;
    notifyListeners();
  }

  void setUserLocation(String location) {
    _userLocation = location;
    notifyListeners();
  }

  void updateEmergencyContact(String type, String contact) {
    _emergencyContacts[type] = contact;
    notifyListeners();
  }

  void setShareLocationForEmergency(bool share) {
    _shareLocationForEmergency = share;
    notifyListeners();
  }

  void setEmergencyMode(bool emergency) {
    _isEmergencyMode = emergency;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Patient history management
  void _addToPatientHistory(String type, Map<String, dynamic> data) {
    _patientHistory.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Keep only last 50 entries
    if (_patientHistory.length > 50) {
      _patientHistory.removeAt(0);
    }
  }

  void clearPatientHistory() {
    _patientHistory.clear();
    notifyListeners();
  }

  // Utility methods
  List<Map<String, dynamic>> getActiveMedicationReminders() {
    return _medicationReminders
        .where((reminder) => reminder['isActive'] == true)
        .toList();
  }

  List<Map<String, dynamic>> getTodaysMedications() {
    final today = DateTime.now();
    return _medicationReminders.where((reminder) {
      if (reminder['isActive'] != true) return false;

      final startDate = DateTime.tryParse(reminder['startDate'] ?? '');
      if (startDate == null) return true;

      return today.isAfter(startDate) || today.isAtSameMomentAs(startDate);
    }).toList();
  }

  bool isInEmergencyState() {
    return _isEmergencyMode ||
        (_currentSymptomData?['severity'] == 'emergency') ||
        (_firstAidRequest?['severity'] == 'life_threatening');
  }

  Map<String, dynamic> generateHealthSummary() {
    return {
      'recentSymptoms': _currentSymptomData,
      'activeMedications': getActiveMedicationReminders(),
      'emergencyMode': _isEmergencyMode,
      'lastUpdated': DateTime.now().toIso8601String(),
      'historyCount': _patientHistory.length,
    };
  }

  // Clear all data (for privacy/logout)
  void clearAllHealthData() {
    _currentSymptomData = null;
    _healthcareSearchData = null;
    _medicationReminders.clear();
    _pillIdentificationData = null;
    _firstAidRequest = null;
    _emergencyContactRequest = null;
    _healthEducationRequest = null;
    _patientHistory.clear();
    _isEmergencyMode = false;
    notifyListeners();
  }

  // Export data for doctor visits
  Map<String, dynamic> exportPatientData() {
    return {
      'symptoms': _currentSymptomData,
      'medications': _medicationReminders,
      'history': _patientHistory,
      'preferences': {
        'language': _preferredLanguage,
        'location': _userLocation,
      },
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}
