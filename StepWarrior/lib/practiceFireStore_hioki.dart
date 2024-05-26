import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_data_load.dart';
import 'node.dart';
import "player.dart";
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: (MyApp())));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<P> playerlist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('データを追加する'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('test1').doc("1").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            GameDataLoad.getAllDocumentsFromSnapshot<P>(
              dataType: "Players",
              fromMap: (data) => P.fromMap(data),
              snapshot: snapshot.data!,
            ).then((List<P> playerlist_now) {
              setState(() {
                playerlist = playerlist_now;
              });
            });
          }
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // addData関数を呼び出してFirestoreにデータを追加
                },
                child: Text('データを追加する'),
              ),
              ElevatedButton(
                onPressed: () {
                  // addData関数を呼び出してFirestoreにデータを追加
                },
                child: Text('データを取ってくる'),
              ),
              (snapshot.hasData) ? Text("${playerlist.isNotEmpty ? playerlist[0].id : 'No data'}") : Text("error"),
              //snapshot.data!.data()は、マップ形式のデータを返します
            ],
          );
        },
      ),
    );
  }
}
