import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bay_flow/firebase_options.dart';
import 'package:bay_flow/Views/home_page_view.dart';
import 'package:bay_flow/Views/login_view.dart';
import 'package:bay_flow/ViewModels/home_page_viewmodel.dart';
import 'package:bay_flow/ViewModels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomePageViewModel()),
      ],
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
      // StreamBuilder listens to auth state — auto switches between login and home
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Color(0xFF07090E),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return HomePage(); // logged in
          }
          return LoginView(); // not logged in
        },
      ),
    );
  }
}