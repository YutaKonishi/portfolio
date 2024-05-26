import 'package:bonfire/bonfire.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/edge.dart';
import 'item.dart';
import 'login.dart';
import 'node.dart';
import 'player.dart';
import 'graph_painter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_data_load.dart';
import 'use_Util.dart';
import 'user.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart'; // rxdart パッケージをインポート

class GameMain extends StatelessWidget {
  const GameMain({super.key});
  // This widget is the root 1f your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameMain!!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GameMainZipPage(),

    );
  }
}

class GameMainZipPage extends ConsumerStatefulWidget {
  GameMainZipPage({super.key});
  @override
  ConsumerState<GameMainZipPage> createState() => GameMainState();
}

class GameMainState extends ConsumerState<GameMainZipPage> {
  int _selectedIndex = 0;
  String gameID  = "1";
  User? currentUser = FirebaseAuth.instance.currentUser;


  void gameIDProvide(WidgetRef ref){
    ref.watch(gameIDProvider.notifier).state = gameID;
  }

  void getUid()async{
    User? currentUser = FirebaseAuth.instance.currentUser;
    String currentUID = currentUser?.uid ?? "";
    DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance.collection("Users").doc(currentUID).get();
    Map<String, dynamic> currentUserData = currentUserDoc.data() as Map<String, dynamic>;
    gameID = currentUserData["gameID"];
    gameIDProvide(ref);
    print(ref.read(gameIDProvider.notifier));
  }

  @override
  void initState() {
    super.initState();
     //try{//現在ログインしているユーザー情報を取得
       getUid();
    //}
        //catch (e) {
          //print('エラー: $e');
        //}
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("タップされた場所は" + _selectedIndex.toString());
      if(_selectedIndex==1) { //ゲームがタップされたら
        //ポイントをデータベースから読み込む処理
      }
    });
  }

  @override
  Widget build(BuildContext context) {
       return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text("ゲーム"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                // ログアウト処理
                // 内部で保持しているログイン情報等が初期化される
                // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
                await FirebaseAuth.instance.signOut();
                // ログイン画面に遷移＋チャット画面を破棄
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('test1').doc(gameID).collection('Nodes').snapshots(),
            builder: (context,snapshot) {
            // 1番目のストリームのデータを処理する
            if (!snapshot.hasData) {
              return CircularProgressIndicator(); // データが来るまでローディングを表示
            }

            final List<DocumentSnapshot> nodeDocuments = snapshot.data!.docs;
            nodeDocuments.sort((a, b) {
              int nameA = int.parse(a.id); // idが整数の名前を持っていると仮定
              int nameB = int.parse(b.id);
              return nameA.compareTo(nameB); // 小さい順に並べ替え
            });


                   return Center(
                     child:InteractiveViewer(
                       constrained: false,
                       child: Stack(
                         children: <Widget>[
                           Column(
                               children: <Widget>[
                                 Text("保有ポイント:" + '${ref.watch(playerPointProvider)}',
                                   style: TextStyle(color: Colors.black, fontSize: 20), textAlign: TextAlign.center,selectionColor: Colors.indigo,),
                                 Text(
                                   '獲得スコア:' + '${ref.watch(playerProvider)[ref.watch(playerIDProvider)].score}',
                                   style: TextStyle(color: Colors.black, fontSize: 20), textAlign: TextAlign.center,),
                                 Text(
                                   '相手スコア:' + '${ref.watch(playerProvider)[ref.watch(playerIDProvider)%2+1].score}',
                                   style: TextStyle(color: Colors.black, fontSize: 20), textAlign: TextAlign.center,),
                               ]
                           ),
                           Container(
                               color: Colors.brown.shade500.withOpacity(0.7),
                               height:  MediaQuery.of(context).size.height*20,
                               width:  MediaQuery.of(context).size.width*20,
                               child:Stack(
                                 children: [
                                   for (int i = 0; i < 69; i++)...{
                                      EdgeWidget(edge_id: i, nodeDocuments: nodeDocuments),
                                   },
                                   for (int i = 0; i < 48; i++)...{//nodeの数を返る時node.dartのchangeNodeIDの値を変える
                                      NodeWidget(node_id: i, nodeDocuments: nodeDocuments),
                                   }

                                 ],
                               )
                           ),
                           SizedBox(width: 10), //余白の大きさを指定
                         ],
                       ),
                     ),
                   );
             },
   ),
  );
}
}
