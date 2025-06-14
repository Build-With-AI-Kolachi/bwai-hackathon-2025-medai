import 'package:doctai/controllers/language_controller.dart';
import 'package:doctai/controllers/live_ai_calling_agent_controller.dart';
import 'package:doctai/view/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MedAIApp());
}

class MedAIApp extends StatelessWidget {
  const MedAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LiveAICallingAgentController(),
        )
      ],
      child: MaterialApp(
        title: 'MedAI',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'SF Pro Display',
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
