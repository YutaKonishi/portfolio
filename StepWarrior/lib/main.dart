import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project/DocumentSnapshotPractice.dart';
import 'package:project/gamemainstreamzip.dart';
import 'package:project/item.dart';
import 'package:project/login.dart';
import 'package:project/practiceFireStore.dart';
import 'gamemain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'walk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';


//pageの管理
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: (ChatApp())));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => MyAppState();
}


class MyAppState extends ConsumerState<MyApp> {

  int _selectedIndex = 0;

  var _pages = <Widget>[//表示ページの管理
    Walk(),
    GameMainZipPage(),
    ItemPage(),
  ];

  void _onItemTapped(int index) {//bottomNavigation
    setState(() {
      _selectedIndex = index;
      print("タップされた場所は" + _selectedIndex.toString());
    });
  }

  // This widget is the root of your application.
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walking!!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility),
              label: '歩数確認画面',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.adb),
              label: 'ゲーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.ad_units),
              label: 'アイテム一覧',
            ),
          ],
          currentIndex: _selectedIndex,//選択中のインデックス
          onTap: _onItemTapped,//タップで選択中のインデックスを変更
        ),
      ),
    );
  }
}