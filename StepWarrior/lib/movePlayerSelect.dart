import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/player.dart';

import 'edge.dart';
import 'node.dart';
import 'nodeMove.dart';



class MovePlayerSelectPage extends ConsumerStatefulWidget {
  MovePlayerSelectPage({super.key});
  @override
  ConsumerState<MovePlayerSelectPage> createState() => MovePlayerSelectState();
}

class MovePlayerSelectState extends ConsumerState<MovePlayerSelectPage> {
  int _selectedIndex = 0;
  String gameID  = "1";
  User? currentUser = FirebaseAuth.instance.currentUser;
  int edgeLength =0 ;

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
    edgeLength = ref.read(edgeProvider).length;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("移動したいマスを選択してください    保持数:${ref.watch(playerProvider)[ref.watch(playerIDProvider)].item1}"),
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
                        Text("保持数:" + '${ref.watch(playerProvider)[ref.watch(playerIDProvider)].item1}',
                          style: TextStyle(color: Colors.black, fontSize: 20), textAlign: TextAlign.center,selectionColor: Colors.indigo,),
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
                          for (int i = 0; i < 48; i++)...{
                            NodeWidgeMovePlayerSelect(node_id: i, nodeDocuments: nodeDocuments),
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
