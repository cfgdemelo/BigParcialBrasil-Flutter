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
      if (data != null && data is List<dynamic>) {
        setState(() {
 _competitors = data;
        });
      }
    });

    messagesRef.onValue.listen((event) async {
      final data = event.snapshot.value;
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
    final competitorsRef = database.ref(competitorsRefName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Realtime DB Data'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_subtitle, style: TextStyle(fontSize: 16)),
                Text(_message, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: competitorsRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null && snapshot.data!.snapshot.value is List<dynamic>) {
                  final competitors = snapshot.data!.snapshot.value as List<dynamic>;
                  return ListView.builder(
                    itemCount: competitors.length,
                    itemBuilder: (context, index) {
                      final competitor = competitors[index] as Map<dynamic, dynamic>;
                      return CompetitorListItem(competitor: competitor);
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(_footer, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}

class CompetitorListItem extends StatelessWidget {
  final Map<dynamic, dynamic> competitor;

  const CompetitorListItem({Key? key, required this.competitor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(competitor['photo'] ?? ''),
        radius: 30,
      ),
      title: Text(competitor['name'] ?? 'Unknown Competitor'),
      trailing: ElevatedButton(
        onPressed: () {
          // TODO: Implement voting logic here
          print('Voted for ${competitor['name']}');
        },
        child: const Text('Votar'),
      ),
    );
  }
}
