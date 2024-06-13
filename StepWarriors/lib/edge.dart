import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/graph_painter.dart';
import 'package:flutter/cupertino.dart';
import 'graph_painter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project/edge.dart';
import 'package:project/node.dart';
import "graph_painter.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

final edgeProvider = StateProvider((ref) =>
 [Edge(id: 0, startPoint: 23, endPoint: 20, cost: 10),
  Edge(id: 1, startPoint: 20, endPoint: 21, cost: 10),
  Edge(id: 2, startPoint: 21, endPoint: 22, cost: 15),
  Edge(id: 3, startPoint: 22, endPoint: 23, cost: 30),
  Edge(id: 4, startPoint: 14, endPoint: 13, cost: 20),
  Edge(id: 5, startPoint: 13, endPoint: 8, cost: 10),
  Edge(id: 6, startPoint: 8, endPoint: 9, cost: 50),
  Edge(id: 7, startPoint: 14, endPoint: 11, cost: 40),
  Edge(id: 8, startPoint: 11, endPoint: 12, cost: 40),
  Edge(id: 9, startPoint: 12, endPoint: 10, cost: 30),
  Edge(id: 10, startPoint: 10, endPoint: 9, cost: 50),
  Edge(id: 11, startPoint: 18, endPoint: 17, cost: 20),
  Edge(id: 12, startPoint: 17, endPoint: 16, cost: 5),
  Edge(id: 13, startPoint: 16, endPoint: 15, cost: 40),
  Edge(id: 14, startPoint: 15, endPoint: 19, cost: 40),
  Edge(id: 15, startPoint: 19, endPoint: 18, cost: 40),
  Edge(id: 16, startPoint: 17, endPoint: 19, cost: 40),
  Edge(id: 17, startPoint: 24, endPoint: 25, cost: 30),
  Edge(id: 18, startPoint: 25, endPoint: 26, cost: 40),
  Edge(id: 19, startPoint: 24, endPoint: 27, cost: 40),
  Edge(id: 20, startPoint: 27, endPoint: 29, cost: 40),
  Edge(id: 21, startPoint: 29, endPoint: 28, cost: 40),
  Edge(id: 22, startPoint: 28, endPoint: 25, cost: 40),
  Edge(id: 23, startPoint: 28, endPoint: 30, cost: 40),
  Edge(id: 24, startPoint: 30, endPoint: 29, cost: 40),
  Edge(id: 25, startPoint: 30, endPoint: 46, cost: 80),
  Edge(id: 26, startPoint: 4, endPoint: 3, cost: 40),
  Edge(id: 27, startPoint: 3, endPoint: 2, cost: 40),
  Edge(id: 28, startPoint: 2, endPoint: 31, cost: 5),
  Edge(id: 29, startPoint: 31, endPoint: 0, cost: 40),
  Edge(id: 30, startPoint: 0, endPoint: 5, cost: 30),
  Edge(id: 31, startPoint: 5, endPoint: 6, cost: 20),
  Edge(id: 32, startPoint: 6, endPoint: 7, cost: 10),
  Edge(id: 33, startPoint: 7, endPoint: 1, cost: 10),
  Edge(id: 34, startPoint: 1, endPoint: 4, cost: 30),
  Edge(id: 35, startPoint: 2, endPoint: 1, cost: 40),
  Edge(id: 36, startPoint: 1, endPoint: 0, cost: 40),
  Edge(id: 37, startPoint: 35, endPoint: 36, cost: 30),
  Edge(id: 38, startPoint: 36, endPoint: 37, cost: 20),
  Edge(id: 39, startPoint: 37, endPoint: 38, cost: 10),
  Edge(id: 40, startPoint: 32, endPoint: 34, cost: 20),
  Edge(id: 41, startPoint: 32, endPoint: 33, cost: 60),
  Edge(id: 42, startPoint: 34, endPoint: 37, cost: 40),
  Edge(id: 43, startPoint: 34, endPoint: 35, cost: 40),
  Edge(id: 44, startPoint: 44, endPoint: 45, cost: 60),
  Edge(id: 45, startPoint: 44, endPoint: 42, cost: 30),
  Edge(id: 46, startPoint: 44, endPoint: 43, cost: 20),
  Edge(id: 47, startPoint: 43, endPoint: 41, cost: 30),
  Edge(id: 48, startPoint: 42, endPoint: 40, cost: 40),
  Edge(id: 49, startPoint: 40, endPoint: 39, cost: 15),
  Edge(id: 50, startPoint: 39, endPoint: 41, cost: 40),
  Edge(id: 51, startPoint: 24, endPoint: 18, cost: 50),
  Edge(id: 52, startPoint: 20, endPoint: 14, cost: 50),
  Edge(id: 53, startPoint: 14, endPoint: 16, cost: 40),
  Edge(id: 54, startPoint: 15, endPoint: 14, cost: 40),
  Edge(id: 55, startPoint: 4, endPoint: 8, cost: 100),
  Edge(id: 56, startPoint: 39, endPoint: 36, cost: 60),
  Edge(id: 57, startPoint: 31, endPoint: 39, cost: 40),
  Edge(id: 58, startPoint: 0, endPoint: 35, cost: 50),
  Edge(id: 59, startPoint: 24, endPoint: 19, cost: 40),
  Edge(id: 60, startPoint: 19, endPoint: 23, cost: 10),
  Edge(id: 61, startPoint: 40, endPoint: 31, cost: 40),
  Edge(id: 62, startPoint: 10, endPoint: 8, cost: 40),
  Edge(id: 63, startPoint: 10, endPoint: 11, cost: 40),
  Edge(id: 64, startPoint: 9, endPoint: 12, cost: 20),
  Edge(id: 65, startPoint: 35, endPoint: 31, cost: 40),
  Edge(id: 66, startPoint: 35, endPoint: 39, cost: 60),
  Edge(id: 67, startPoint: 40, endPoint: 41, cost: 40),
  Edge(id: 68, startPoint: 42, endPoint: 43, cost: 20)
]
);
//エッジを表すクラス
class Edge {
  final int id; //エッジのid
  final int startPoint; //エッジの始点ノード番号
  final int endPoint; //エッジの終点ノード番号
  int cost; //移動に必要なコスト

  Edge({required this.id,required this.startPoint, required this.endPoint, required this.cost});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startPoint': startPoint,
      'endPoint': endPoint,
      'cost': cost,
    };
  }

  factory Edge.fromMap(Map<String,dynamic>map){
    return Edge(
        id: map["id"],
        startPoint: map["startPoint"],
        endPoint: map["endPoint"],
        cost: map["cost"]);
    }
}

class EdgeWidget extends ConsumerWidget {
  int edge_id;//何番のノードか
  List<DocumentSnapshot> nodeDocuments;
  EdgeWidget({super.key, required this.edge_id, required this.nodeDocuments});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return CustomPaint(
          painter: EdgePainter(nodeDocuments: nodeDocuments, edge: ref.watch(edgeProvider)[edge_id], cost: ref.watch(edgeProvider)[edge_id].cost)
    );
  }
}