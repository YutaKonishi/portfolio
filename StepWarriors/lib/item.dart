import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/gamemainstreamzip.dart';
import 'package:project/player.dart';
import 'game_data_load.dart';
import 'login.dart';
import 'movePlayerSelect.dart';
import 'node.dart';


class ItemPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var l = ref.watch(playerProvider);
    fetchPlayerData(ref);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("アイテム一覧"),
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
      body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Text("保有ポイント:"+"${ref.watch(playerPointProvider)}",
                   style: TextStyle(fontSize: 20),),
              SizedBox(height: 10),
              Container(//Containerの中でないとListViewはColumnに書けない
                  height: MediaQuery.of(context).size.height/2,
                  width: MediaQuery.of(context).size.width,
                  child:Scrollbar(
                      thumbVisibility: true,
                      thickness: 10,
                      radius: const Radius.circular(10),
                      scrollbarOrientation: ScrollbarOrientation.right,
                      child:ListView(
                        children: [
                          _menuItem(context, ref, l, 1, Icon(Icons.accessible_forward_rounded)),
                          _menuItem(context, ref, l, 2, Icon(Icons.account_balance)),
                          _menuItem(context, ref, l, 3, Icon(Icons.account_balance)),
                          _menuItem(context, ref, l, 4, Icon(Icons.account_balance)),
                          _menuItem(context, ref, l, 5, Icon(Icons.account_balance)),
                          _menuItem(context, ref, l, 6, Icon(Icons.account_balance)),
                          _menuItem(context, ref, l, 7, Icon(Icons.account_balance)),
                          _menuItem(context, ref, l, 8, Icon(Icons.account_balance)),
                        ],
                      )
                  )
              ),
            ],
          )
      ),
    );
  }
}
/*
dartではオブジェクトやリストは参照渡しであるため
List<P> buy(WidgetRef ref, List<P> l, int price){
  var result = ref.watch(playerProvider);
  result[0].point = 10;
  return result;
}
としてもresultのアドレスは変更されないため更新されない
List<P> buy(int playerID, List<P> l, int price){
  l[playerID].point -= price;
  return [...l];//スプレッド演算子を使うとうまくいく　新たなリストが作られる
}
*/
void buy(WidgetRef ref, int playerID, List<P> l, int price){
  l[playerID].usedpoint += price;
  var point = ref.watch(playerPointProvider);
  ref.watch(playerPointProvider.notifier).state = point - price;
  GameDataLoad.saveDocuments(
      collectionPath: "test1",
      gameID: ref.read(gameIDProvider),
      dataType: "Players",
      dataList: l,
      toMap: (data) => data.toMap()
  );
}

final menuprice = [1, 2, 3, 4, 5, 6, 7];

Widget _menuItem(BuildContext context, WidgetRef ref ,List<P> l, int num, Icon icon) {
  return Container(
    decoration: new BoxDecoration(
        border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
    ),
    child:ListTile(
      leading: icon,
      title: num==1 ?
        Text("瞬間移動: 保持数${ref.watch(playerProvider)[ref.watch(playerIDProvider)].item1}", style: TextStyle(color:Colors.black, fontSize: 18.0)):
        Text("Coming Soon!", style: TextStyle(color:Colors.black, fontSize: 18.0)),
      onTap: () {
        if(num==1){
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MovePlayerSelectPage()));
        }
        // リストの場合は変数のアドレスが変わる（新たにリストが生成される)と変更を通知しwidget更新？　
        //→　~.state=[P(id: 0, point: 0, score: 0),P(id: 1, point: 76, score: 36),P(id: 2, point: 80, score: 2)]とすると更新される
      },
    ),
  );
}
