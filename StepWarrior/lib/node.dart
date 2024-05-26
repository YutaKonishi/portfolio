//import 'dart:html';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/edge.dart';
import 'package:project/graph_painter.dart';
import 'package:project/player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project/walk.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart'; //fadeinimageに透過画像を適用するため
import 'package:bonfire/bonfire.dart';
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
import 'package:project/player.dart';
import 'game_data_load.dart';
import 'dart:math' as math;

final audioPlayer = AudioPlayer();

class Node {
  final int id;
  final int type;//0がノーマル　1がイベント 2がアイテム
  final int posiX;//x座標
  final int posiY;//y座標
  final List<int> nextNode;//隣接ノード番号のリスト
  int nc;//nodeの塗るコスト
  int ns;//nodeを塗ると得られるスコア
  int owner;//誰のノードか
  int player;//誰がいるか　0が誰もいない
  Node({required this.id, required this.type, required this.posiX, required this.posiY, required this.nextNode, required this.nc, required this.ns, required this.owner, required this.player});

  Map<String,dynamic> toMap(){
    return{
      "id": id,
      "type": type,
      "posiX":posiX,
      "posiY":posiY,
      "nextNode":nextNode,
      "nc":nc,
      "ns":ns,
      "owner":owner,
      "player":player
    };
  }

  factory Node.fromMap(Map<String,dynamic> map){
    return Node(
        id: map["id"],
        type: map["type"],
        posiX: map["posiX"],
        posiY: map["posiY"],
        nextNode: (map["nextNode"] as List<dynamic>?)?.cast<int>() ?? [],  // デフォルト値を設定
        nc: map["nc"],
        ns: map["ns"],
        owner: map["owner"],
        player: map["player"]
    );
  }
}
final gameIDProvider = StateProvider((ref) => "1");
//NodeのWidget
class NodeWidget extends ConsumerWidget {
  int node_id;//何番のノードか
  List<DocumentSnapshot> nodeDocuments;

  NodeWidget({super.key, required this.node_id,  required this.nodeDocuments});

  int graphScale = 70; //グラフの座標を何倍して表示するか 同時にEdgePainterクラスの値も変更する
  Offset origin = Offset (50, 50); //グラフの表示の下限

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = 60; //円の大きさ
    double width = height;
    int player_id = nodeDocuments[node_id]["player"];//このノードにいるplayer
    int owner_id =  nodeDocuments[node_id]["owner"];
    fetchPlayerData(ref);

    return GestureDetector(
        onTap: () {//タップされた時の処理
          selectBottomMenu(context, ref, nodeDocuments, node_id, player_id, owner_id);
        },

        child: Stack(

          children: [
            Container(
              child: Center(//playerのいるマスに表示
                  child: (player_id==0 && nodeDocuments[node_id]["type"] == 0)?
                  Text("\n C:${nodeDocuments[node_id]["nc"]} \n S:${nodeDocuments[node_id]["ns"]}"):
                  Stack(
                    clipBehavior: Clip.none,//はみ出た部分切り取られないように
                    children: [
                      Positioned(
                          top: -20,
                          left: 5,
                          child:
                               (player_id==1 && nodeDocuments[node_id]["type"] == 1 )?
                                 Stack(
                                   clipBehavior: Clip.none,//はみ出た部分切り取られないように
                                   children: [
                                     Positioned(
                                       left : 15,
                                       child: Image.asset("assets/images/gardening_hiryou.png", width: 40, height: 40),
                                     ),
                                     Positioned(
                                       child: Image.asset("assets/images/character_tomato.png", width: 40, height: 40),
                                     )
                                 ],)
                              :(player_id==1 && nodeDocuments[node_id]["type"] == 2 )?
                               Stack(
                                 clipBehavior: Clip.none,//はみ出た部分切り取られないように
                                 children: [
                                   Positioned(
                                     left : 15,
                                     child: Image.asset("assets/images/mark_question.png", width: 40, height: 40),
                                   ),
                                   Positioned(
                                     child: Image.asset("assets/images/character_tomato.png", width: 40, height: 40),
                                   )
                                 ],)
                              :(player_id==1 && nodeDocuments[node_id]["type"] == 3 )?
                               Stack(
                                 clipBehavior: Clip.none,//はみ出た部分切り取られないように
                                 children: [
                                   Positioned(
                                     left : 25,
                                     child: Image.asset("assets/images/job_nouka.png", width: 40, height: 40),
                                   ),
                                   Positioned(
                                     child: Image.asset("assets/images/character_tomato.png", width: 40, height: 40),
                                   )
                                 ],)
                              :(player_id==2 && nodeDocuments[node_id]["type"] == 1 )?
                               Stack(
                                 clipBehavior: Clip.none,//はみ出た部分切り取られないように
                                 children: [
                                   Positioned(
                                     left : 15,
                                     child: Image.asset("assets/images/gardening_hiryou.png", width: 40, height: 40),
                                   ),
                                   Positioned(
                                     child: Image.asset("assets/images/character_cabbage.png", width: 40, height: 40),
                                   )
                                 ],)
                              :(player_id==2 && nodeDocuments[node_id]["type"] == 2 )?
                               Stack(
                                 clipBehavior: Clip.none,//はみ出た部分切り取られないように
                                 children: [
                                   Positioned(
                                     left : 15,
                                     child: Image.asset("assets/images/mark_question.png", width: 40, height: 40),
                                   ),
                                   Positioned(
                                     child: Image.asset("assets/images/character_cabbage.png", width: 40, height: 40),
                                   )
                                 ],)
                              :(player_id==2 && nodeDocuments[node_id]["type"] == 3 )?
                               Stack(
                                 clipBehavior: Clip.none,//はみ出た部分切り取られないように
                                 children: [
                                   Positioned(
                                     left : 25,
                                     child: Image.asset("assets/images/job_nouka.png", width: 40, height: 40),
                                   ),
                                   Positioned(
                                     child: Image.asset("assets/images/character_cabbage.png", width: 40, height: 40),
                                   )
                                 ],)
                              :player_id==1 ? Image.asset("assets/images/character_tomato.png", width: 40, height: 40)
                              :player_id==2 ? Image.asset("assets/images/character_cabbage.png", width: 40, height: 40)
                              :nodeDocuments[node_id]["type"] == 1 ? Image.asset("assets/images/gardening_hiryou.png", width: 40, height: 40)
                              :nodeDocuments[node_id]["type"] == 2 ? Image.asset("assets/images/mark_question.png", width: 40, height: 40)
                              :nodeDocuments[node_id]["type"] == 3 ? Image.asset("assets/images/job_nouka.png", width: 40, height: 40)
                              : Container()
                      ),
                      Positioned(
                        top: 0,
                        left: 20,
                        child: Text("\n C:${nodeDocuments[node_id]["nc"]} \n S:${nodeDocuments[node_id]["ns"]}")
                      ),
                    ],
                  )
              ),
              decoration: BoxDecoration(
                //プレイヤーが所有しているマスならそのプレイヤの色。誰も所有していなくて、typeが1ボーナスマスなら紫、2ギャンブルマスならオレンジ、それ以外のマスなら緑
                color:  ref.watch(playerProvider)[owner_id].color,
                     /* nodeDocuments[node_id]["owner"] != 0 ? ref.watch(playerProvider)[owner_id].color
                    : (nodeDocuments[node_id]["type"] == 1 ? Colors.yellow
                    : (nodeDocuments[node_id]["type"] == 2 ? Colors.purple
                    : (nodeDocuments[node_id]["type"] == 3 ? Colors.blue
                    : ref.watch(playerProvider)[owner_id].color)))*/

                shape: BoxShape.circle,
              ),
              height: height,
              width: width,
              margin: EdgeInsets.fromLTRB(nodeDocuments[node_id]["posiX"].toDouble() * graphScale + origin.dx-(height/2), nodeDocuments[node_id]["posiY"].toDouble() * graphScale + origin.dy-(width/2), 0, 0),
            ),
          ],
        )
    );
  }
}

int edgeCost(WidgetRef ref, int node_id, int next_nodeid){//ノード間の枝のコストを求める
  var edge_list = ref.watch(edgeProvider);
  for(var edge in edge_list){
    if(edge.startPoint==next_nodeid && edge.endPoint==node_id){
      return edge.cost;
    }else if(edge.startPoint==node_id && edge.endPoint==next_nodeid){
      return edge.cost;
    }
  }
  return 10000;
}

void showBottomMenu0(BuildContext context){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          child: Center(
              child:Column(
                children: <Widget>[
                  Text("このマスは既にあなたのマスです").animate().fadeIn(duration: 1.seconds),//animation練習
                  ElevatedButton(onPressed: () =>Navigator.pop(context), child: Text('戻る'),
                    style: ElevatedButton.styleFrom(side: BorderSide( width: 0.5)),
                  ),
                ],
              )

          ),
        );
      }
  );
}

//ボーナススコアを獲得したときに表示する画面
void showBottomMenu4(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int node_id, double bonus_score){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          child: Center(
              child:Column(
                children: <Widget>[
                  Text("ボーナススコア" + bonus_score.toInt().toString() + "を獲得しました！" ),
                  ElevatedButton(onPressed: () => Navigator.pop(context),
                  child: Text('戻る'),
                    style: ElevatedButton.styleFrom(side: BorderSide( width: 0.5)),
                  ),
                ],
              )
          ),
        );
      }
  );
  paint(context, ref, nodeDocuments, node_id, bonus_score, 0);
  print("paint");
}

//ギャンブルマスを塗ってスコアが変わったときに表示する画面
void showBottomMenu5(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int node_id, double gamble_rate, int player_id){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          child: Center(
              child:Column(
                children: <Widget>[
                  Text("スコアが" + gamble_rate.toString() + "倍になりました。" ),
                  Text("現在のスコア\n" + ref.watch(playerProvider)[player_id].score.toString(),
                      style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
                  ElevatedButton(onPressed: () => Navigator.pop(context),
                    child: Text('戻る'),
                    style: ElevatedButton.styleFrom(side: BorderSide( width: 0.5)),
                  ),
                ],
              )
          ),
        );
      }
  );
  paint(context, ref, nodeDocuments, node_id, gamble_rate, 0);
  print("paint");
}


void showBottomMenu6(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int node_id, int itemnum, int player_id){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          child: Center(
              child:Column(
                children: <Widget>[
                  Text("アイテム" + itemnum.toString() + "を獲得しました。" ),
                  ElevatedButton(onPressed: () => Navigator.pop(context),
                    child: Text('戻る'),
                    style: ElevatedButton.styleFrom(side: BorderSide( width: 0.5)),
                  ),
                ],
              )
          ),
        );
      }
  );
  paint(context, ref, nodeDocuments, node_id, 0, itemnum);
  print("paint");
}

//playerからポイントをcost分使う
void pay(int playerID, List<P> l, int cost,WidgetRef ref){
  l[playerID].usedpoint += cost;
  var point = ref.watch(playerPointProvider);
  ref.watch(playerPointProvider.notifier).state = point - cost;
  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: ref.read(gameIDProvider),
      dataType: "Players",
      dataList: l,
      toMap: (data) => data.toMap()
  );
}

//node番号node_idの所有者変更
void changeColor(int playerID,  List<DocumentSnapshot> nodeDocuments, int node_id,WidgetRef ref){
  DocumentReference docRef = FirebaseFirestore.instance.collection('test1').doc(ref.read(gameIDProvider)).collection("Nodes").doc("${node_id}");

// データを更新
  docRef.update({
    'owner': playerID,
  });
  audioPlayer.play(AssetSource("audios/koto.mp3"));

}

//node番号node__idのコストを2倍（とりあえず適当に2倍)に変更
void changeCost( List<DocumentSnapshot> nodeDocuments, int node_id,WidgetRef ref) {
  DocumentReference docRef = FirebaseFirestore.instance.collection('test1').doc(ref.read(gameIDProvider)).collection("Nodes").doc("${node_id}");

// データを更新
  docRef.update({
    'nc': (nodeDocuments[node_id]["nc"] * 1.5).toInt(),
  });
}

void score(WidgetRef ref, int playerID, List<P> l, int score, List<DocumentSnapshot> nodeDocuments, int node_id){
  l[playerID].score += score;
  ref.watch(playerProvider.notifier).state=[...l];
  if(nodeDocuments[node_id]["owner"] == playerID % 2 + 1){
    l[playerID%2+1].score -= score;
  }

  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: ref.read(gameIDProvider),
      dataType: "Players",
      dataList: l,
      toMap: (data) => data.toMap()
  );
}

//bonusマスにおける特別なスコアの処理
void bonusScore(WidgetRef ref, int playerID, List<P> l, int score, List<DocumentSnapshot> nodeDocuments, int node_id, double bonus_score){
  //bonus scoreの決定と処理
  l[playerID].score += bonus_score.toInt();
  ref.watch(playerProvider.notifier).state=[...l];
  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: ref.read(gameIDProvider),
      dataType: "Players",
      dataList: l,
      toMap: (data) => data.toMap()
  );
}

//gambleマスにおける特別なスコアの処理
void gambleScore(WidgetRef ref, int playerID, List<P> l, int score, List<DocumentSnapshot> nodeDocuments, int node_id, double gamble_rate){
  //bonus scoreの決定と処理
  l[playerID].score = (l[playerID].score * gamble_rate).toInt();
  ref.watch(playerProvider.notifier).state=[...l];
  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: ref.read(gameIDProvider),
      dataType: "Players",
      dataList: l,
      toMap: (data) => data.toMap()
  );
}

//itemマスにおけるアイテムの数の増加の処理
void itemInc(WidgetRef ref, int playerID, List<P> l, List<DocumentSnapshot> nodeDocuments, int node_id, int itemnum){
  //item数の増加
  if(itemnum==1){
    l[playerID].item1 += 1;
  }

  ref.watch(playerProvider.notifier).state=[...l];
  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: ref.read(gameIDProvider),
      dataType: "Players",
      dataList: l,
      toMap: (data) => data.toMap()
  );
}


//node番号node_idの所有者をplayer〇に変える
void paint(BuildContext context, WidgetRef ref,  List<DocumentSnapshot> nodeDocuments, int node_id, double bonus_score, int itemnum) {
  var require_point = nodeDocuments[node_id]["nc"];
  var get_score = nodeDocuments[node_id]["ns"];
  var playerList = ref.watch(playerProvider);
  pay(ref.watch(playerIDProvider), playerList, require_point, ref);
  changeColor(ref.watch(playerIDProvider), nodeDocuments, node_id, ref);
  changeCost(nodeDocuments, node_id, ref);
  //ボーナスマスかどうかに限らずノードに書いているスコアを獲得スコアとして追加
  score(
      ref, ref.watch(playerIDProvider), playerList, get_score, nodeDocuments,
      node_id);

  if (nodeDocuments[node_id]["type"] == 1) { //塗るのがbonusマスの場合、ボーナススコアも追加
    //void bonusScore(WidgetRef ref, int playerID, List<P> l, int score, List<DocumentSnapshot> nodeDocuments, int node_id, int bonus_score){
    bonusScore(
        ref,
        ref.watch(playerIDProvider),
        playerList,
        get_score,
        nodeDocuments,
        node_id,
        bonus_score);
  } else
  if (nodeDocuments[node_id]["type"] == 2) { //塗るのがgambleマスの場合、現状のスコアに倍率をかける
    gambleScore(
        ref,
        ref.watch(playerIDProvider),
        playerList,
        get_score,
        nodeDocuments,
        node_id,
        bonus_score);
  }else if(nodeDocuments[node_id]["type"] == 3){ //塗るのがitemマスの場合、item1の数を1つ増やす
    itemInc(ref, ref.watch(playerIDProvider), playerList, nodeDocuments, node_id, itemnum);
    DocumentReference docRef = FirebaseFirestore.instance.collection('test1').doc(ref.read(gameIDProvider)).collection("Nodes").doc("${node_id}");
    docRef.update({
      'type': 0,//アイテムを受け取るとt通常のマスにする
    });

  }else{//何もないマスを塗った時

    print("aa");
    //Navigator.pop(context);
  }
  if(Random().nextInt(100)<20){//確率90/100でchangeNodeIDのtypeを3にする　ただしtypeがもともと0の時のみ　もしもともと3なら消す
    int changeNodeID = Random().nextInt(7);//nextIntの値はnodeの数に合わせる
    if(node_id != changeNodeID && nodeDocuments[changeNodeID]["type"]==0 && (nodeDocuments[changeNodeID]["owner"]==ref.watch(playerIDProvider)%2+1 || nodeDocuments[changeNodeID]["owner"]==0)){//自身のマスに出現しても塗れないから自身のマス以外
      DocumentReference docRef = FirebaseFirestore.instance.collection('test1').doc(ref.read(gameIDProvider)).collection("Nodes").doc("${changeNodeID}");
      docRef.update({
        'type': 3,
      });
    }else if(nodeDocuments[changeNodeID]["type"]==3){
      DocumentReference docRef = FirebaseFirestore.instance.collection('test1').doc(ref.read(gameIDProvider)).collection("Nodes").doc("${changeNodeID}");
      docRef.update({
        'type': 0,
      });
    }

  }
}

void showBottomMenu1(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int node_id, int player_id) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      var point = ref.watch(playerPointProvider);
      var require_point = nodeDocuments[node_id]["nc"];
      double bonus_rate = (math.Random().nextInt(10) + 1) / 10;
      double bonus_score = (nodeDocuments[node_id]["ns"] * bonus_rate); // 塗ったマスのスコアの0.1倍から1倍のボーナススコアを付与
      double gamble_rate = (3 * math.Random().nextInt(2) + 1) / 2; //スコアが確率1/2で2倍、確率1/2で0.5倍
      //print(bonus_rate.toString() + " " + bonus_score.toString());

      return Container(
        height: 380,
        child: Center(
          child: Column(
            children: <Widget>[
              Text('このマスを塗りますか？', style: TextStyle(fontSize: 20)),
              SizedBox(height: 15), //余白
              Text("保有ポイント\n" + "$point",
                  style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              Text("必要ポイント\n" + "$require_point",
                  style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              Text("獲得スコア\n" + "${nodeDocuments[node_id]["ns"]}",
                  style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 現在のボトムシートを閉じる
                      if (nodeDocuments[node_id]["type"] == 1){
                          showBottomMenu4(context, ref, nodeDocuments, node_id, bonus_score);
                      }else if (nodeDocuments[node_id]["type"] == 2){
                          showBottomMenu5(context, ref, nodeDocuments, node_id, gamble_rate, player_id);
                      }else if (nodeDocuments[node_id]["type"] == 3){
                          showBottomMenu6(context, ref, nodeDocuments, node_id, 1, player_id);//１はアイテム番号
                      }else {
                        paint(context, ref, nodeDocuments, node_id, 0, 0);
                      }
                    },
                    child: Text("はい"),
                    style: ElevatedButton.styleFrom(side: BorderSide(width: 0.5)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('いいえ'),
                    style: ElevatedButton.styleFrom(side: BorderSide(width: 0.5)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}



void showBottomMenu2(BuildContext context, int point, int require_point){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          child: Center(
              child:Column(
                children: <Widget>[
                  Text("ポイントが足りません"),
                  SizedBox(height: 15),
                  Text("保有ポイント\n"+"$point",//現在play中の人の番号入れる
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                  Text("必要ポイント\n"+"$require_point",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                  SizedBox(height: 15),
                  ElevatedButton(onPressed: () =>Navigator.pop(context), child: Text('戻る'),
                    style: ElevatedButton.styleFrom(side: BorderSide( width: 0.5)),
                  ),
                ],
              )

          ),
        );
      }
  );
}


//next_idからnode_idにrequire_pointを使って移動
void comePlayer(List<DocumentSnapshot> nodeDocuments, List<P> l, int next_nodeid, int node_id, int player,WidgetRef ref){//next_nodeidからnode_idのnodeに番号playerが来るとき
  DocumentReference docRef = FirebaseFirestore.instance.collection('test1').doc(ref.read(gameIDProvider)).collection("Nodes").doc("${next_nodeid}");

// データを更新
  docRef.update({
    'player': 0,
  });
  DocumentReference docRef2 = FirebaseFirestore.instance.collection('test1').doc(ref.read(gameIDProvider)).collection("Nodes").doc("${node_id}");

// データを更新
  docRef2.update({
    'player': player,
  });
  audioPlayer.play(AssetSource("audios/button1.mp3"));

  l[ref.watch(playerIDProvider)].loc = node_id;
  ref.watch(playerProvider.notifier).state=[...l];
  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: ref.read(gameIDProvider),
      dataType: "Players",
      dataList: l,
      toMap: (data) => data.toMap()
  );
}

//next_idからnode_idにrequire_pointを使って移動
void move(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int require_point, int next_nodeid, int node_id){
  var playerList = ref.watch(playerProvider);
  pay(ref.watch(playerIDProvider), playerList, require_point,ref);
  comePlayer(nodeDocuments, ref.watch(playerProvider),next_nodeid, node_id, ref.watch(playerIDProvider),ref);
  Navigator.pop(context);
}
void showBottomMenu3(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int require_point, int next_nodeid, int node_id) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        var point = ref.watch(playerPointProvider);
        return Container(
          height: 250,
          child: Center(
              child: Column(
                children: <Widget>[
                  Text('このマスに移動しますか？',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 15),
                  Text("保有ポイント\n" + "$point", //現在play中の人の番号入れる
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                  Text("必要ポイント\n" + "$require_point",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(onPressed: () =>
                          move(context, ref, nodeDocuments, require_point, next_nodeid, node_id), child: Text("はい"),
                        style: ElevatedButton.styleFrom(side: BorderSide(width: 0.5)),
                      ),
                      ElevatedButton(onPressed: () => Navigator.pop(context),
                        child: Text('いいえ'),
                        style: ElevatedButton.styleFrom(side: BorderSide(width: 0.5)),
                      ),
                    ],
                  ),

                ],
              )
          ),
        );
      }
  );
}

//nodeがタップされたときに確認などの画面を表示(showBottomMenu)する
void selectBottomMenu(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int node_id, int player_id, int owner_id){
  if(player_id != ref.watch(playerIDProvider)){//タップされたのが自身のいるマスでないかを確認
    if(player_id != ref.watch(playerIDProvider) % 2 + 1) { // かつ相手のいるマスでないかを確認
      var nextnode_list = nodeDocuments[node_id]["nextNode"];
      //タップされたノードの隣のノードに自身がいるかを確認
      for (var next_nodeid in nextnode_list) {
        if (nodeDocuments[next_nodeid]["player"] == ref.watch(playerIDProvider)) {
          var require_point = edgeCost(ref, node_id, next_nodeid);
          if (ref.watch(playerPointProvider) >= require_point) { //移動するポイントが足りる
            showBottomMenu3(
                context, ref, nodeDocuments, require_point, next_nodeid,
                node_id);

          }else { //足りない
            showBottomMenu2(
                context, ref.watch(playerPointProvider), require_point);
          }
        }
      }
    }
  }else{//タップされたのが自身のマス
    if (player_id == owner_id){//既に自身のマス
      showBottomMenu0(context);
      audioPlayer.play(AssetSource("audios/button2.mp3"));
    }else{//自身のマスでない
      var require_point = nodeDocuments[node_id]["nc"];
      if (ref.watch(playerPointProvider) >= require_point){//塗るポイントが足りる
        showBottomMenu1(context, ref, nodeDocuments, node_id, player_id);
      }
      else{//足りない
        showBottomMenu2(context, ref.watch(playerPointProvider), require_point);
      }
    }
  }
}



