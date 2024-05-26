import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/player.dart';

import 'node.dart';


void move2(BuildContext context, WidgetRef ref,List<P> l, List<DocumentSnapshot> nodeDocuments, int playerLocNodeID, int node_id){
  comePlayer(nodeDocuments, ref.watch(playerProvider), playerLocNodeID, node_id, ref.watch(playerIDProvider),ref);
  l[ref.watch(playerIDProvider)].item1 -= 1;
  ref.watch(playerProvider.notifier).state = [...l];
  Navigator.pop(context);
}

void selectBottomMenu1(BuildContext context, WidgetRef ref, List<DocumentSnapshot> nodeDocuments, int node_id, int player_id, int owner_id){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          child: Center(
              child:Column(
                children: <Widget>[
                  Text("移動しますか"),
                  SizedBox(height: 15),
                  Text("保有ポイント\n"+"${ref.watch(playerPointProvider)}",//現在play中の人の番号入れる
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                  Text("保持数\n"+"${ref.watch(playerProvider)[ref.watch(playerIDProvider)].item1}",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(onPressed: () => move2(context, ref, ref.watch(playerProvider), nodeDocuments, ref.watch(playerProvider)[ref.watch(playerIDProvider)].loc, node_id), child: Text("はい"),
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

void selectBottomMenu2(BuildContext context, WidgetRef ref){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          child: Center(
              child:Column(
                children: <Widget>[
                  Text("アイテムが足りません"),
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

class NodeWidgeMovePlayerSelect extends ConsumerWidget {
  int node_id;//何番のノードか
  List<DocumentSnapshot> nodeDocuments;

  NodeWidgeMovePlayerSelect({super.key, required this.node_id, required this.nodeDocuments});

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
          if(ref.watch(playerProvider)[ref.watch(playerIDProvider)].item1>0){
            if(nodeDocuments[node_id]["player"]!=ref.watch(playerIDProvider) % 2 + 1){
              selectBottomMenu1(context, ref, nodeDocuments, node_id, player_id, owner_id);
            }
          }else{
            selectBottomMenu2(context, ref);
          }
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
