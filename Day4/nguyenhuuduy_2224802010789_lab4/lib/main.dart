import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nguyenhuuduy_2224802010789_lab4/views/add_contact_page.dart';
import 'package:nguyenhuuduy_2224802010789_lab4/views/home.dart';
import 'package:nguyenhuuduy_2224802010789_lab4/views/login_page.dart';
import 'package:nguyenhuuduy_2224802010789_lab4/views/sign_up_page.dart';
import 'controllers/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDd30BLdkN_LJFIkt-nJECgv9W6qw8FJiw',
  appId: '1:275335338042:web:1387ab9e0439d434b0fd03',
  messagingSenderId: '275335338042',
  projectId: 'todosapp-lab4a',
  authDomain: 'todosapp-lab4a.firebaseapp.com',
  storageBucket: 'todosapp-lab4a.firebasestorage.app',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts App',
      theme: ThemeData(
        textTheme: GoogleFonts.soraTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade800),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const CheckUser(),
        "/home": (context) => const Homepage(),
        "/signup": (context) => const SignUpPage(),
        "/login": (context) => const LoginPage(),
        "/add": (context) => const AddContact()
      },
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService().isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}