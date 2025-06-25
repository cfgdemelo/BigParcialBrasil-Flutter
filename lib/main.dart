import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'dart:developer';

const String messagesRefName = 'messages';
const String competitorsRefName = 'competitors';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState(); 
}

class _MyHomePageState extends State<MyHomePage> {
  final database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  String _title = 'Loading...';
  String _subtitle = 'Loading...';
  String _message = 'Loading...';
  String _footer = 'Loading...';
  List<dynamic> _competitors = [];

  void _activateListeners() {
    final competitorsRef = database.ref(competitorsRefName);
    final messagesRef = database.ref(messagesRefName);

    competitorsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print('Competitors data: $data');
      if (data != null && data is Map) {
        setState(() {
          _competitors = data.values.toList();
        });
      }
    });

    messagesRef.onValue.listen((event) async {
      final data = event.snapshot.value;
      log('Messages data: ${data.toString()}');
      if (data != null && data is Map) {
        setState(() {
          _title = data['title'] ?? 'No title';
          _subtitle = data['subtitle'] ?? 'No subtitle';
          _message = data['message'] ?? 'No message';
          _footer = data['footer'] ?? 'No footer';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Realtime DB Data'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(_title),
          Text(_subtitle),
          Text(_message),
          Expanded(child: Container()), // Use Expanded to push the footer to the bottom
          Text(_footer),
        ],
      ),
    );
  }
}
