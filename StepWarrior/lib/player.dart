import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/walk.dart';
import 'game_data_load.dart';

final player1UsedPointProvider = StateProvider((ref) => 0);
final player1ScoreProvider = StateProvider((ref) => 0);
final player1LocProvider = StateProvider((ref) => 0);
final player1Item1Provider = StateProvider((ref) => 0);

final player2UsedPointProvider = StateProvider((ref) => 0);
final player2ScoreProvider = StateProvider((ref) => 0);
final player2LocProvider = StateProvider((ref) => 0);
final player2Item1Provider = StateProvider((ref) => 0);

var first_login = true;//初めのログインか
void fetchPlayerData(WidgetRef ref) async {//プレイヤーデータの取得
  try {
    //現在ログインしているユーザー情報を取得
    User? currentUser = FirebaseAuth.instance.currentUser;
    String currentUID = currentUser?.uid ?? "";
    DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance.collection("Users").doc(currentUID).get();
    Map<String, dynamic> currentUserData = currentUserDoc.data() as Map<String, dynamic>;

    //ゲームIDとプレイヤーIDを取得
    String gameID = currentUserData["gameID"];
    int playerID = currentUserData["playerID"];
    print("userID:$currentUID");
    print('playerID: $playerID');
    print("gameID: $gameID");

    //プレイヤーIDを取得したものに書き換え
    ref.watch(playerIDProvider.notifier).state = playerID;


    // Firestoreの参照を取得
    CollectionReference users = FirebaseFirestore.instance.collection('test1').doc(gameID).collection("Players");
    // コレクションからドキュメントを取得
    QuerySnapshot querySnapshot = await users.get();
    // 取得したドキュメントを処理
    var i=0;
    if(first_login){
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if(i==1){
          print('usedpoint: ${data["usedpoint"]}');
          print('score: ${data["score"]}');
          ref.watch(player1UsedPointProvider.notifier).state=data["usedpoint"];
          ref.watch(player1ScoreProvider.notifier).state=data["score"];
          ref.watch(player1LocProvider.notifier).state=data["loc"];
          ref.watch(player1Item1Provider.notifier).state=data["item1"];

        }
        if(i==2){
          print('usedpoint: ${data["usedpoint"]}');
          print('score: ${data["score"]}');
          ref.watch(player2UsedPointProvider.notifier).state=data["usedpoint"];
          ref.watch(player2ScoreProvider.notifier).state=data["score"];
          ref.watch(player2LocProvider.notifier).state=data["loc"];
          ref.watch(player2Item1Provider.notifier).state=data["item1"];

          //ここでplayerprovider更新する
        }
        i=i+1;
      });
      first_login = false;
    }

  } catch (e) {
    print('エラー: $e');
  }
}

//pointとscore引き継げるがwalk.dartの画面から速くゲーム画面に遷移するとproviderの読み取りの方が速く0が代入される
final playerProvider = StateProvider((ref) =>
[P(id: 0, usedpoint: 0, score: 0, color: Colors.brown, loc: -1, item1: 0),
  P(id: 1, usedpoint: ref.watch(player1UsedPointProvider), score: ref.watch(player1ScoreProvider), color: Colors.red, loc: ref.watch(player1LocProvider), item1: ref.watch(player1Item1Provider)),
  P(id: 2, usedpoint: ref.watch(player2UsedPointProvider), score: ref.watch(player2ScoreProvider), color: Colors.green, loc:  ref.watch(player2LocProvider),  item1: ref.watch(player2Item1Provider))]);
final playerIDProvider = StateProvider((ref) => 1);

final playerPointProvider = StateProvider((ref) => ref.watch(walkCurrentProvider)-(ref.watch(playerProvider)[ref.watch(playerIDProvider)].usedpoint));

class P {
  final int id;//player番号
  int usedpoint;//使用ポイント
  int score;//保有スコア
  final Color color;
  int loc;
  int item1;
  P({required this.id, required this.usedpoint, required this.score, required this.color, required this.loc, required this.item1});

  // PオブジェクトをMapに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usedpoint': usedpoint,
      'score': score,
      'color': color.value,
      'loc' : loc,
      'item1': item1
    };
  }

  // FirestoreのデータをPオブジェクトに変換するファクトリメソッド
  factory P.fromMap(Map<String, dynamic> map) {
    return P(
      id: map['id'],
      usedpoint: map['usedpoint'],
      score: map['score'],
      color: Color(map['color']),
      loc: map['loc'],
      item1: map['item1']
    );
  }
}
