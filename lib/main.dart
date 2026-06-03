import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vybe/core/theme/app_theme.dart';
import 'package:vybe/features/reels/presentation/pages/reels_page.dart';
import 'package:vybe/firebase_options.dart';
import 'package:vybe/seed/seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await DatabaseSeeder.seedVideosIfNeeded();

  runApp(const VybeApp());
}

class VybeApp extends StatelessWidget {
  const VybeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYbe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ReelsPage(),
    );
  }
}
