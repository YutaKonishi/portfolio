import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/player.dart';



class Example extends ConsumerWidget {
  void addData() async {
    try {
      // Firestoreへの参照を取得
      CollectionReference users = FirebaseFirestore.instance.collection('test_take');

      //AiuthenticationのユーザーID取得
      final myId = FirebaseAuth.instance.currentUser!.uid;
      // 追加するデータ
      Map<String, dynamic> data = {//firestoreはmapでデータを管理
        "id": myId,
        'name': 'John Doe',
        'age': 30,
        'email': 'johndoe@example.com',
      };

      // Firestoreにデータを追加
      await users.add(data);

      print('データがFirestoreに追加されました');//左下のrunの▷押すとコンソール
    } catch (e) {
      print('エラー: $e');
    }
  }

  void fetchData(WidgetRef ref) async {

    try {
      // Firestoreの参照を取得
      CollectionReference users = FirebaseFirestore.instance.collection('test1').doc("1").collection("Players");

      // コレクションからドキュメントを取得
      QuerySnapshot querySnapshot = await users.get();

      // 取得したドキュメントを処理
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('id: ${data}');

        print('score: ${data["score"]}');
      });
    } catch (e) {
      print('エラー: $e');
    }
  }
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
          title: Text('データを追加する'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('test_take').snapshots(),//Streamとは、データオブジェクトを一つずつ渡していく川の流れのようなもの
          builder: (context, snapshot) {
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // addData関数を呼び出してFirestoreにデータを追加
                    addData();
                  },
                  child: Text('データを追加する'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // addData関数を呼び出してFirestoreにデータを追加
                    fetchData(ref);
                  },
                  child: Text('データを取ってくる'),
                ),
                (snapshot.hasData) ?
                Text("${documents[0]["id"]}"):Text("error")
                //snapshot.data!.data()は、マップ形式のデータを返します
              ],
            );
          },
        ),
      ),
    );
  }

  Stream<int> _counterStream() async* {//これをStreamにかくと1ずつ増えていく
    int counter = 0;
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      counter++;
      yield counter;
    }
  }//データを追加　
}