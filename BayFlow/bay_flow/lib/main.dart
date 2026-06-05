import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bay_flow/Views/home_page_view.dart';
import 'package:bay_flow/ViewModels/home_page_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bay_flow/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => HomePageViewModel(),
      child: BayFlowApp(),
    ),
  );
}

class BayFlowApp extends StatelessWidget {
  const BayFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BayFlow',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}