import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/player.dart';

final playerIDProvider = StateProvider((ref) => 2);

class ExampleDocumentSnapshot extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //AiuthenticationのユーザーID取得
    final myId = FirebaseAuth.instance.currentUser!.uid;
    return MaterialApp(
      title: 'Walking!!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:Scaffold(
        appBar: AppBar(
          title: Text('DocumenSnapshot'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('test_take').doc("6TEQONbxEF2LdMQMbzIx").snapshots(), //Streamとは、データオブジェクトを一つずつ渡していく川の流れのようなもの
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            final DocumentSnapshot documents = snapshot.data!;
            return
                (snapshot.hasData) ?
                Text("${documents["id"]}"):Text("error");
                //snapshot.data!.data()は、マップ形式のデータを返します
          },
        ),
      ),
    );
  }
}
