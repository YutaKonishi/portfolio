//import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
// 更新可能なデータ
class UserState extends ChangeNotifier {
  User? user;

  void setUser(User newUser) {
    user = newUser;
    notifyListeners();
  }
}


/*
void main() async {
  // 初期化処理を追加
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChatApp());
}

void test(){
  var insertData = {"content":"wow!",};
  FirebaseFirestore.instance.collection("testCol").add(insertData);
}*/


class ChatApp extends StatelessWidget {
  // ユーザーの情報を管理するデータ
  final UserState userState = UserState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>(
      create: (context) => UserState(),
      child: MaterialApp(
        // アプリ名
        title: 'Login',
        theme: ThemeData(
          // テーマカラー
          primarySwatch: Colors.orange,
        ),
        // ログイン画面を表示
        home: LoginPage(),
      ),
    );
  }
}

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);

    return Scaffold(
          body:
          SingleChildScrollView(
           child:Center(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50),
                  // メールアドレス入力
                  TextFormField(
                    decoration: InputDecoration(labelText: 'メールアドレス'),
                    onChanged: (String value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  // パスワード入力
                  TextFormField(
                    decoration: InputDecoration(labelText: 'パスワード'),
                    obscureText: true,
                    onChanged: (String value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    // メッセージ表示
                    child: Text(infoText),
                  ),
                  Container(
                    width: double.infinity,
                    // ユーザー登録ボタン
                    child: ElevatedButton(
                      child: Text('ユーザー登録'),
                      onPressed: () async {
                        try {
                          // メール/パスワードでユーザー登録
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          final result = await auth.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          // ユーザー情報を更新
                          DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection("Admin").doc("usersData").get();
                          Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
                          int userNum = adminData["number"];
                          int gameNum = adminData["gameNumber"];
                          userNum++;

                          //新規プレイヤーが奇数番目ならゲームを一つ増やす
                          if(userNum%2 == 1){
                            gameNum++;
                          }

                          await FirebaseFirestore.instance.collection("Users").doc(result.user!.uid).set({
                            "id": result.user!.uid,
                            "email": result.user!.email,
                            "gameID": gameNum.toString(),
                            "playerID":2 - (userNum % 2) //偶数番目がPlayer2になるようにする
                            // 他のユーザー情報をここに追加する
                          });
                          await FirebaseFirestore.instance.collection("Admin").doc("usersData").set({
                            "number": userNum,
                            "gameNumber":gameNum
                          });

                          userState.setUser(result.user!);
                          // ユーザー登録に成功した場合
                          // チャット画面に遷移＋ログイン画面を破棄
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return MyApp();
                            }),
                          );
                        } catch (e) {
                          // ユーザー登録に失敗した場合
                          setState(() {
                            infoText = "登録に失敗しました：${e.toString()}";
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    // ログイン登録ボタン
                    child: OutlinedButton(
                      child: Text('ログイン'),
                      onPressed: () async {
                        try {
                          // メール/パスワードでログイン
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          final result = await auth.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          // ユーザー情報を更新
                          userState.setUser(result.user!);
                          // ログインに成功した場合
                          // チャット画面に遷移＋ログイン画面を破棄
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return MyApp();
                            }),
                          );
                        } catch (e) {
                          // ログインに失敗した場合
                          setState(() {
                            infoText = "ログインに失敗しました：${e.toString()}";
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
       ),
    );
  }
}


// チャット画面用Widget
class ChatPage extends StatelessWidget {
  ChatPage();

  @override
  Widget build(BuildContext context) {
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;

    return Scaffold(
      /*appBar: AppBar(
        title: Text('チャット'),
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
      ),*/
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("testCol").snapshots(),
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    final List<DocumentSnapshot> documents = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context,index){
                        return ListTile(
                          title: Text(documents[index]["content"]),
                        );
                      },
                    );
                  }
                  return Center(
                    child: Text("Working!"),
                  );
                } ,
              )),

        ],
      ),
    );
  }
}