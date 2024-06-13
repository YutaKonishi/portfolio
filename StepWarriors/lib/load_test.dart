import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'game_data_load.dart';
import 'player.dart';
import "edge.dart";
import 'node.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//実行するとデータベース初期化できる

void main() async {
  // 初期化処理を追加
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 使用例
  final p1 = P(id: 2, usedpoint: 300, score: 150, color: Colors.blue, loc: 0, item1: 0);
  final e1 = Edge(id: 0, startPoint: 1, endPoint: 1, cost: 150);
  final n1 = Node(id: 0, type: 0, posiX: 0, posiY: 0, nextNode: [2,3], nc: 1, ns: 1, owner: 0, player: 0);

  // PlayerオブジェクトをFirestoreに保存
  GameDataLoad.saveDocument(
      collectionPath: "test1",
      gameID: "1",
      dataType: "Players",
      data: p1,
      toMap: (data) => data.toMap()
  );

  GameDataLoad.saveDocument(
      collectionPath: "test1",
      gameID: "1",
      dataType: "Edges",
      data: e1,
      toMap: (data) => data.toMap()
  );

  GameDataLoad.saveDocument(
      collectionPath: "test1",
      gameID: "1",
      dataType: "Nodes",
      data: n1,
      toMap: (data) => data.toMap()
  );

  final nodes =
  [Node(id: 0, type: 0, posiX: 17, posiY: 13, nextNode: [31, 5, 1, 35], nc: 25, ns: 30, owner: 0, player: 0), //長野
    Node(id: 1, type: 0, posiX: 15, posiY: 14, nextNode: [7, 4, 2, 0], nc: 15, ns: 10, owner: 0, player: 0), //岐阜
    Node(id: 2, type: 2, posiX: 16, posiY: 11, nextNode: [3, 31, 1], nc: 18, ns: 15, owner: 0, player: 0), //富山
    Node(id: 3, type: 0, posiX: 14, posiY: 11, nextNode: [4, 2], nc: 12, ns: 10, owner: 0, player: 0), //石川
    Node(id: 4, type: 0, posiX: 13, posiY: 12, nextNode: [3, 1, 8], nc: 5, ns: 8, owner: 0, player: 1), //福井
    Node(id: 5, type: 0, posiX: 18, posiY: 15, nextNode: [0, 6], nc: 8, ns: 10, owner: 0, player: 0), //山梨
    Node(id: 6, type: 0, posiX: 17, posiY: 16, nextNode: [5, 7], nc: 10, ns: 7, owner: 0, player: 0), //静岡
    Node(id: 7, type: 1, posiX: 15, posiY: 16, nextNode: [6, 1], nc: 20, ns: 18, owner: 0, player: 0), //愛知
    Node(id: 8, type: 0, posiX: 13, posiY: 15, nextNode: [10, 13, 9, 4], nc: 14, ns: 10, owner: 0, player: 2), //滋賀
    Node(id: 9, type: 0, posiX: 13, posiY: 18, nextNode: [8, 10, 12], nc: 10, ns: 10, owner: 0, player: 0), //三重
    Node(id: 10, type: 0, posiX: 12, posiY: 17, nextNode: [8, 12, 9, 11], nc: 8, ns: 5, owner: 0, player: 0), //奈良
    Node(id: 11, type: 1, posiX: 11, posiY: 16, nextNode: [10, 14, 12], nc: 15, ns: 10, owner: 0, player: 0), //大阪
    Node(id: 12, type: 0, posiX: 11, posiY: 18, nextNode: [9, 11, 10], nc: 20, ns: 20, owner: 0, player: 0), //和歌山
    Node(id: 13, type: 0, posiX: 12, posiY: 14, nextNode: [14, 8], nc: 25, ns: 30, owner: 0, player: 0), //京都
    Node(id: 14, type: 0, posiX: 10, posiY: 14, nextNode: [13, 11, 20, 16, 15], nc: 16, ns: 10, owner: 0, player: 0), //兵庫
    Node(id: 15, type: 0, posiX: 8, posiY: 14, nextNode: [16, 19, 14], nc: 5, ns: 10, owner: 0, player: 0), //岡山
    Node(id: 16, type: 2, posiX: 8, posiY: 12, nextNode: [17, 15, 14], nc: 10, ns: 5, owner: 0, player: 0), //鳥取
    Node(id: 17, type: 0, posiX: 6, posiY: 12, nextNode: [18, 16, 19], nc: 18, ns: 10, owner: 0, player: 0), //島根
    Node(id: 18, type: 0, posiX: 4, posiY: 13, nextNode: [17, 19, 24], nc: 25, ns: 10, owner: 0, player: 0), //山口
    Node(id: 19, type: 0, posiX: 6, posiY: 14, nextNode: [15, 18, 17, 23, 24], nc: 16, ns: 17, owner: 0, player: 0), //広島
    Node(id: 20, type: 0, posiX: 9, posiY: 16, nextNode: [23, 21, 14], nc: 19, ns: 8, owner: 0, player: 0), //香川
    Node(id: 21, type: 0, posiX: 9, posiY: 18, nextNode: [20, 22], nc: 22, ns: 10, owner: 0, player: 0), //徳島
    Node(id: 22, type: 1, posiX: 7, posiY: 18, nextNode: [21, 23], nc: 30, ns: 20, owner: 0, player: 0), //高知
    Node(id: 23, type: 0, posiX: 7, posiY: 16, nextNode: [19, 20, 22], nc: 20, ns: 18, owner: 0, player: 0), //愛媛
    Node(id: 24, type: 2, posiX: 3, posiY: 14, nextNode: [25, 27, 18, 19], nc: 20, ns: 40, owner: 0, player: 0), //福岡
    Node(id: 25, type: 0, posiX: 2, posiY: 15, nextNode: [24, 26, 28], nc: 10, ns: 10, owner: 0, player: 0), //佐賀
    Node(id: 26, type: 0, posiX: 1, posiY: 16, nextNode: [25], nc: 40, ns: 80, owner: 0, player: 0), //長崎
    Node(id: 27, type: 0, posiX: 4, posiY: 16, nextNode: [24, 29], nc: 20, ns: 10, owner: 0, player: 0), //大分
    Node(id: 28, type: 0, posiX: 3, posiY: 17, nextNode: [29, 25, 30], nc: 20, ns: 10, owner: 0, player: 0), //熊本
    Node(id: 29, type: 0, posiX: 4, posiY: 18, nextNode: [27, 28, 30], nc: 16, ns: 16, owner: 0, player: 0), //宮崎
    Node(id: 30, type: 0, posiX: 2, posiY: 19, nextNode: [28, 29, 46], nc: 10, ns: 10, owner: 0, player: 0), //鹿児島
    Node(id: 31, type: 0, posiX: 18, posiY: 10, nextNode: [2, 0, 39, 40, 35], nc: 10, ns: 10, owner: 0, player: 0), //新潟
    Node(id: 32, type: 1, posiX: 20, posiY: 15, nextNode: [34, 33], nc: 30, ns: 30, owner: 0, player: 0), //東京
    Node(id: 33, type: 0, posiX: 20, posiY: 16, nextNode: [32], nc: 10, ns: 30, owner: 0, player: 0), //神奈川
    Node(id: 34, type: 0, posiX: 20, posiY: 14, nextNode: [32, 37, 35], nc: 15, ns: 10, owner: 0, player: 0), //埼玉
    Node(id: 35, type: 0, posiX: 19, posiY: 12, nextNode: [31, 36, 34, 0, 39], nc: 14, ns: 10, owner: 0, player: 0), //群馬
    Node(id: 36, type: 0, posiX: 21, posiY: 12, nextNode: [35, 37, 39], nc: 12, ns: 10, owner: 0, player: 0), //栃木
    Node(id: 37, type: 0, posiX: 22, posiY: 14, nextNode: [36, 38, 34], nc: 10, ns: 10, owner: 0, player: 0), //茨城
    Node(id: 38, type: 1, posiX: 22, posiY: 16, nextNode: [37], nc: 50, ns: 100, owner: 0, player: 0), //千葉
    Node(id: 39, type: 2, posiX: 22, posiY: 10, nextNode: [40, 41, 36, 31, 35], nc: 25, ns: 45, owner: 0, player: 0), //福島
    Node(id: 40, type: 0, posiX: 21, posiY: 8, nextNode: [31, 42, 39, 41], nc: 15, ns: 10, owner: 0, player: 0), //山形
    Node(id: 41, type: 0, posiX: 23, posiY: 8, nextNode: [43, 39, 40], nc: 15, ns: 16, owner: 0, player: 0), //宮城
    Node(id: 42, type: 0, posiX: 21, posiY: 6, nextNode: [44, 40, 43], nc: 8, ns: 10, owner: 0, player: 0), //秋田
    Node(id: 43, type: 0, posiX: 23, posiY: 6, nextNode: [44, 41, 42], nc: 7, ns: 10, owner: 0, player: 0), //岩手
    Node(id: 44, type: 0, posiX: 22, posiY: 4, nextNode: [45, 42, 43], nc: 15, ns: 10, owner: 0, player: 0), //青森
    Node(id: 45, type: 3, posiX: 25, posiY: 1, nextNode: [44], nc: 50, ns: 46, owner: 0, player: 0), //北海道
    Node(id: 46, type: 3, posiX: 1, posiY: 23, nextNode: [30], nc: 60, ns: 43, owner: 0, player: 0), //沖縄
    Node(id: 47, type: 0, posiX: 4, posiY: 4, nextNode: [0], nc: 1000, ns: 200, owner: 0, player: 0), //飛び地
  ];


  final players = [P(id: 0, usedpoint: 0, score: 0, color: Colors.green, loc:0, item1: 0),
    P(id: 1, usedpoint: 0, score: 0, color: Colors.blue, loc: 4, item1: 4),
    P(id: 2, usedpoint: 0, score: 0, color: Colors.red, loc: 8, item1: 4)];//locの値は各プレイヤーの開始ノード番号に合わせる

  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: "1",
      dataType: "Nodes",
      dataList: nodes,
      toMap: (data) => data.toMap()
  );

  /*GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: "1",
      dataType: "Edges",
      dataList: edges,
      toMap: (data) => data.toMap()
  );*/

  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: "1",
      dataType: "Players",
      dataList: players,//playerのリストデータ
      toMap: (data) => data.toMap()
  );

  final player = GameDataLoad.getDocument<Node>(
      collectionPath: "test1",
      gameID: "1",
      dataType: "Nodes",
      documentID: "1",
      fromMap: (data) => Node.fromMap(data)
  );

  final player2 = await player;
  print(player2!.id);


}