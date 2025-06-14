import 'package:doctai/view/agents/tools/tools.dart';
import 'package:doctai/controllers/live_ai_calling_agent_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:async';
import 'dart:developer';
import 'package:record/record.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'dart:typed_data';

class MedAIHelpAssistantView extends StatefulWidget {
  const MedAIHelpAssistantView({super.key, required this.title});

  final String title;

  @override
  State<MedAIHelpAssistantView> createState() => _MedAIHelpAssistantViewState();
}

class _MedAIHelpAssistantViewState extends State<MedAIHelpAssistantView> {
  final LiveGenerativeModel _liveModel =
      FirebaseAI.vertexAI().liveGenerativeModel(
    systemInstruction: Content.text('''
      You are MedAI, a compassionate and knowledgeable healthcare assistant designed to help users with their medical needs. 
      
      Your primary functions include:
      1. **Symptom Analysis**: Listen to symptoms and provide preliminary guidance, always emphasizing when to seek professional care
      2. **Healthcare Navigation**: Help users find nearby medical facilities, pharmacies, and emergency services
      3. **Medication Management**: Assist with pill identification, medication reminders, and basic drug information
      4. **First Aid Guidance**: Provide step-by-step emergency first aid instructions
      5. **Health Education**: Share preventive care information and health tips
      6. **Emergency Support**: Recognize emergency situations and guide users to appropriate immediate care
      
      **Important Guidelines**:
      - Always prioritize user safety and encourage professional medical consultation for serious symptoms
      - Be culturally sensitive and support multiple languages (English, Urdu, Punjabi, Sindhi)
      - For emergency situations, immediately guide users to call emergency services while providing first aid
      - Never diagnose or replace professional medical advice - provide guidance and education only
      - Be empathetic and reassuring, especially in emergency situations
      - Always ask for confirmation before setting reminders or making changes
      - Provide location-appropriate advice considering local healthcare systems
      
      **Emergency Recognition**: 
      Immediately escalate and activate emergency protocols for: chest pain, difficulty breathing, severe bleeding, 
      loss of consciousness, severe allergic reactions, signs of stroke, or any life-threatening situation.
      
      Use the available tools to help users effectively and always confirm actions before executing them.
    '''),
    model: 'gemini-2.0-flash-live-preview-04-09',
    liveGenerationConfig: LiveGenerationConfig(
      speechConfig: SpeechConfig(voiceName: 'fenrir'),
      responseModalities: [ResponseModalities.audio],
    ),
    tools: [
      Tool.functionDeclarations([
        symptomCheckerTool,
        nearbyHealthcareTool,
        medicationReminderTool,
        pillIdentifierTool,
        firstAidGuidanceTool,
        emergencyContactsTool,
        healthEducationTool,
      ]),
    ],
  );

  late LiveSession _session;
  bool _settingUpSession = false;
  bool _sessionOpened = false;
  bool _conversationActive = false;
  StreamController<bool> _stopController = StreamController<bool>();
  bool _audioReady = false;
  final _recorder = AudioRecorder();
  late Stream<Uint8List> inputStream;
  late AudioSource? audioSrc;
  late SoundHandle handle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _stopController.close();
    super.dispose();
  }

  /// AUDIO INITIALIZATION
  Future<void> _initializeAudio() async {
    try {
      await _checkMicPermission();
      await SoLoud.instance.init(sampleRate: 24000, channels: Channels.mono);
      setState(() {
        _audioReady = true;
      });
      log('Audio system initialized successfully');
    } catch (e) {
      log("Error during audio initialization: $e");
      _showErrorDialog(
          "Audio initialization failed. Please check microphone permissions.");
    }
  }

  void _toggleConversation() async {
    _conversationActive
        ? await _stopConversation()
        : await _startConversation();
  }

  Future<void> _startConversation() async {
    setState(() {
      _settingUpSession = true;
    });

    try {
      // Start the live session
      await _toggleLiveGeminiSession();

      // Start recording audio input stream
      inputStream = await _startRecordingStream();
      log('Audio input stream started');

      // Send audio stream to Gemini
      Stream<InlineDataPart> inlineDataStream = inputStream.map((data) {
        return InlineDataPart('audio/pcm', data);
      });
      _session.sendMediaStream(inlineDataStream);

      // Setup audio output
      var audioSource = SoLoud.instance.setBufferStream(
        bufferingType: BufferingType.released,
        bufferingTimeNeeds: 0,
        onBuffering: (isBuffering, handle, time) {
          log('Audio buffering: $isBuffering, Time: $time');
        },
      );
      var soundHandle = await SoLoud.instance.play(audioSource);

      setState(() {
        audioSrc = audioSource;
        handle = soundHandle;
        _conversationActive = true;
        _settingUpSession = false;
      });

      log('Healthcare conversation started successfully');
    } catch (e) {
      log('Error starting conversation: $e');
      _showErrorDialog("Failed to start conversation. Please try again.");
      setState(() {
        _settingUpSession = false;
      });
    }
  }

  Future<void> _stopConversation() async {
    try {
      // Stop recording
      await _stopRecording();

      // Stop audio output
      if (audioSrc != null) {
        SoLoud.instance.setDataIsEnded(audioSrc!);
        await SoLoud.instance.stop(handle);
      }

      // End session
      await _toggleLiveGeminiSession();

      setState(() {
        _conversationActive = false;
      });

      log('Healthcare conversation ended');
    } catch (e) {
      log('Error stopping conversation: $e');
    }
  }

  Future<void> _checkMicPermission() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission required for voice interaction');
    }
  }

  Future<Stream<Uint8List>> _startRecordingStream() async {
    var recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 24000,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
      androidConfig: AndroidRecordConfig(
        audioSource: AndroidAudioSource.voiceCommunication,
      ),
      iosConfig: IosRecordConfig(
        categoryOptions: [IosAudioCategoryOption.defaultToSpeaker],
      ),
    );
    return await _recorder.startStream(recordConfig);
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
  }

  /// GEMINI LIVE SESSION MANAGEMENT
  Future<void> _toggleLiveGeminiSession() async {
    setState(() {
      _settingUpSession = true;
    });

    if (!_sessionOpened) {
      _session = await _liveModel.connect();
      _sessionOpened = true;
      unawaited(_processMessagesContinuously(stopSignal: _stopController));
    } else {
      await _session.close();
      _stopController.add(true);
      await _stopController.close();
      _stopController = StreamController<bool>();
      _sessionOpened = false;
    }

    setState(() {
      _settingUpSession = false;
    });
  }

  Future<void> _processMessagesContinuously({
    required StreamController<bool> stopSignal,
  }) async {
    bool shouldContinue = true;

    stopSignal.stream.listen((stop) {
      if (stop) shouldContinue = false;
    });

    while (shouldContinue) {
      try {
        await for (final response in _session.receive()) {
          LiveServerMessage message = response.message;
          await _handleLiveServerMessage(message);
        }
      } catch (e) {
        log('Error processing messages: $e');
        break;
      }
    }
  }

  Future<void> _handleLiveServerMessage(LiveServerMessage response) async {
    if (response is LiveServerContent) {
      if (response.modelTurn != null) {
        await _handleLiveServerContent(response);
      }
      if (response.turnComplete != null && response.turnComplete!) {
        await _handleTurnComplete();
      }
      if (response.interrupted != null && response.interrupted!) {
        log('Healthcare conversation interrupted');
      }
    }

    if (response is LiveServerToolCall && response.functionCalls != null) {
      await _handleLiveServerToolCall(response);
    }
  }

  Future<void> _handleLiveServerContent(LiveServerContent response) async {
    log('Received healthcare response from MedAI');
    final partList = response.modelTurn?.parts;
    if (partList != null) {
      for (final part in partList) {
        if (part is TextPart) {
          await _handleTextPart(part);
        } else if (part is InlineDataPart) {
          await _handleInlineDataPart(part);
        } else {
          log('Received part with type ${part.runtimeType}');
        }
      }
    }
  }

  Future<void> _handleLiveServerToolCall(LiveServerToolCall response) async {
    final functionCalls = response.functionCalls;
    if (functionCalls != null && functionCalls.isNotEmpty) {
      debugPrint(
          'Healthcare function calls: ${functionCalls.map((fc) => fc.name).toString()}');

      for (var functionCall in functionCalls) {
        switch (functionCall.name) {
          case 'checkSymptoms':
            checkSymptomsCall(context, functionCall);
            break;
          case 'findNearbyHealthcare':
            findNearbyHealthcareCall(context, functionCall);
            break;
          case 'setMedicationReminder':
            setMedicationReminderCall(context, functionCall);
            break;
          case 'identifyPill':
            identifyPillCall(context, functionCall);
            break;
          case 'provideFirstAid':
            provideFirstAidCall(context, functionCall);
            break;
          case 'getEmergencyContacts':
            getEmergencyContactsCall(context, functionCall);
            break;
          case 'getHealthEducation':
            getHealthEducationCall(context, functionCall);
            break;
          default:
            log('Unknown healthcare function: ${functionCall.name}');
        }
      }
    }
  }

  Future<void> _handleInlineDataPart(InlineDataPart part) async {
    // Handle audio response from MedAI
    if (part.mimeType.startsWith('audio')) {
      var audioOutputSrc = audioSrc;
      if (audioOutputSrc != null) {
        SoLoud.instance.addAudioDataStream(audioOutputSrc, part.bytes);
      }
    }
  }

  Future<void> _handleTextPart(TextPart part) async {
    log('MedAI response: ${part.text}');

    // Check for emergency keywords in response
    final emergencyKeywords = [
      'emergency',
      'urgent',
      'call 911',
      'immediate',
      'life-threatening'
    ];
    if (emergencyKeywords
        .any((keyword) => part.text.toLowerCase().contains(keyword))) {
      final appState =
          Provider.of<LiveAICallingAgentController>(context, listen: false);
      appState.setEmergencyMode(true);
    }
  }

  Future<void> _handleTurnComplete() async {
    log('MedAI finished responding');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Emergency Detected'),
          content: const Text(
              'This appears to be an emergency situation. Please call emergency services immediately.'),
          backgroundColor: Colors.red[50],
          actions: [
            TextButton(
              onPressed: () {
                // Launch emergency dialer
                Navigator.of(context).pop();
              },
              child: const Text('Call Emergency',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<LiveAICallingAgentController>();
    final isEmergency = appState.isInEmergencyState();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isEmergency
            ? Colors.red[700]
            : Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Icon(
              Icons.health_and_safety,
              color: isEmergency ? Colors.white : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: TextStyle(
                color: isEmergency ? Colors.white : null,
                fontWeight: isEmergency ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        actions: [
          if (isEmergency)
            IconButton(
              onPressed: _showEmergencyDialog,
              icon: const Icon(Icons.emergency, color: Colors.white),
              tooltip: 'Emergency Help',
            ),
          if (_settingUpSession)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _audioReady ? _toggleConversation : null,
              icon: _conversationActive
                  ? Icon(
                      Icons.mic_off,
                      color: isEmergency ? Colors.white : Colors.red,
                      size: 28,
                    )
                  : Icon(
                      Icons.mic,
                      color: isEmergency ? Colors.white : Colors.green,
                      size: 28,
                    ),
              tooltip: _conversationActive
                  ? 'End Conversation'
                  : 'Start Healthcare Conversation',
            ),
        ],
      ),
      body: Column(
        children: [
          if (isEmergency)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Emergency mode activated. Seek immediate medical attention.',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to MedAI',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _conversationActive
                                ? 'I\'m listening and ready to help with your healthcare needs.'
                                : 'Tap the microphone to start a conversation about your health.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                    children: [
                      _buildQuickActionCard(
                        icon: Icons.medical_services,
                        title: 'Symptom Check',
                        subtitle: 'Describe your symptoms',
                        onTap: () {
                          // Quick symptom check
                        },
                      ),
                      _buildQuickActionCard(
                        icon: Icons.local_hospital,
                        title: 'Find Healthcare',
                        subtitle: 'Nearby clinics & hospitals',
                        onTap: () {
                          // Find healthcare providers
                        },
                      ),
                      _buildQuickActionCard(
                        icon: Icons.medication,
                        title: 'Medications',
                        subtitle: 'Reminders & pill ID',
                        onTap: () {
                          // Medication management
                        },
                      ),
                      _buildQuickActionCard(
                        icon: Icons.emergency,
                        title: 'First Aid',
                        subtitle: 'Emergency guidance',
                        color: Colors.red,
                        onTap: () {
                          // First aid guidance
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Active medication reminders
                  if (appState.medicationReminders.isNotEmpty) ...[
                    Text(
                      'Today\'s Medications',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...appState.getTodaysMedications().map((med) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.medication),
                            title: Text(med['medicationName'] ?? 'Unknown'),
                            subtitle:
                                Text('${med['dosage']} - ${med['frequency']}'),
                            trailing: Icon(
                              med['isActive'] == true
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              color: med['isActive'] == true
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),

          // Status bar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _conversationActive ? Icons.mic : Icons.mic_off,
                  size: 16,
                  color: _conversationActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _conversationActive
                      ? 'Listening...'
                      : _audioReady
                          ? 'Ready to start'
                          : 'Initializing audio...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
