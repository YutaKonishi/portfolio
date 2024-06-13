//import 'dart:html';
import 'package:bonfire/bonfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'node.dart';
import 'edge.dart';
import 'player.dart';


/*class NodePainter extends CustomPainter {
  final Node node;
  final P player;

  NodePainter({required this.node, required this.player});

  @override
  void paint(Canvas canvas, Size size) {
    const int graphScale = 20; //グラフの座標を何倍して表示するか
    const Point origin = Point (50, 50); //グラフの表示の下限

    // ノードを描画
    const double nodeRadius = 20;
    Paint paint = Paint()..color = player.color;
    canvas.drawCircle(Offset(node.posi.x.toDouble() * graphScale + origin.x, node.posi.y.toDouble() * graphScale + origin.y), nodeRadius, paint); //数字はノードの円の大きさ

  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}*/

class EdgePainter extends CustomPainter {
  final List<DocumentSnapshot> nodeDocuments;
  final Edge edge;
  int cost;

  EdgePainter({required this.nodeDocuments, required this.edge, required this.cost});

  @override
  void paint(Canvas canvas, Size size) {
    const int graphScale = 70; //グラフの座標を何倍して表示するか 同時にnodeWidgetクラスも変更する
    const Offset origin = Offset(50, 50); //グラフの表示の下限

    // エッジを描画
    Paint paint = Paint()
      ..color = Colors.black;
    canvas.drawLine(Offset(
        nodeDocuments[edge.startPoint]["posiX"] * graphScale + origin.dx,
        nodeDocuments[edge.startPoint]["posiY"].toDouble() * graphScale + origin.dy),
        Offset(nodeDocuments[edge.endPoint]["posiX"] * graphScale + origin.dx,
            nodeDocuments[edge.endPoint]["posiY"].toDouble() * graphScale + origin.dy),
        paint);
    Offset middlePoint = Offset((nodeDocuments[edge.startPoint]["posiX"] +
        nodeDocuments[edge.endPoint]["posiX"]) * graphScale / 2 + origin.dx,
        (nodeDocuments[edge.startPoint]["posiY"] +
            nodeDocuments[edge.endPoint]["posiY"]) * graphScale / 2 +
            origin.dy);
    //middle_point上にテキストを表示したい。


    //これ以降,@override以前まで0508に追加by小西
    // テキストを描画
    TextSpan span = TextSpan(
      text:  cost.toString(), //エッジの中点に表示するコスト
      style: TextStyle(color: Colors.black, fontSize: 16),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, middlePoint - Offset(tp.width / 2, tp.height / 2));
  }




@override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


}