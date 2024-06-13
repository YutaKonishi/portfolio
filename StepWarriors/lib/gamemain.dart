import 'package:bonfire/bonfire.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/edge.dart';
import 'item.dart';
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
      home: GameMainPage(),

    );
  }
}

class GameMainPage extends ConsumerStatefulWidget {
  GameMainPage({super.key});
  @override
  ConsumerState<GameMainPage> createState() => GameMainState();
}

class GameMainState extends ConsumerState<GameMainPage> {
  int _selectedIndex = 0;
  String GameID  = "1";
  User? currentUser = FirebaseAuth.instance.currentUser;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("タップされた場所は" + _selectedIndex.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentuid = currentUser?.uid ?? "";
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("GameMain!"),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('test1').doc("1").collection('Nodes').snapshots(),
            builder: (context,snapshot1) {
            // 1番目のストリームのデータを処理する
            final List<DocumentSnapshot> nodeDocuments = snapshot1.data!.docs;
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('test1').doc("1").collection('Players').snapshots(),
                builder: (context, snapshot2) {
                // 2番目のストリームのデータを処理する
                final List<DocumentSnapshot> edgeDocuments = snapshot2.data!.docs;
                return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('test1').doc("1").collection('Edges').snapshots(),
                    builder: (context, snapshot3) {

                    final List<DocumentSnapshot> playerDocuments = snapshot3.data!.docs;

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
                               ]
                           ),
                           Container(
                               color: Colors.black38,
                               height:  MediaQuery.of(context).size.height,
                               width:  MediaQuery.of(context).size.width*2,
                               child:const Stack(
                                 children: [
                                   //NodeWidget(node_id: 0, nodeDocuments: nodeDocuments, playerDocuments: playerDocuments, edgeDocuments: edgeDocuments),

                                   /*EdgeWidget(edge_id: 0),
                                   EdgeWidget(edge_id: 1),
                                   EdgeWidget(edge_id: 2),
                                   EdgeWidget(edge_id: 3),
                                   EdgeWidget(edge_id: 4),
                                   EdgeWidget(edge_id: 5),
                                   EdgeWidget(edge_id: 6),
                                   EdgeWidget(edge_id: 7),
                                   EdgeWidget(edge_id: 8),
                                   EdgeWidget(edge_id: 9),

                                   NodeWidget(node_id: 0),
                                   NodeWidget(node_id: 1),
                                   NodeWidget(node_id: 2),
                                   NodeWidget(node_id: 3),
                                   NodeWidget(node_id: 4),
                                   NodeWidget(node_id: 5),
                                   NodeWidget(node_id: 6),
                                   NodeWidget(node_id: 7),*/
                                 ],
                               )
                           ),
                           SizedBox(width: 10), //余白の大きさを指定
                         ],
                       ),
                     ),
                   );
             },
          );
        }
      );
    },
   ),
  );
}
}
