import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vybe/core/app/vybe_app.dart';
import 'package:vybe/firebase_options.dart';
import 'package:vybe/seed/seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  try {
    await DatabaseSeeder.seedVideosIfNeeded();
  } catch (error) {
    debugPrint('Startup seed skipped: $error');
  }

  runApp(const VybeApp());
}
