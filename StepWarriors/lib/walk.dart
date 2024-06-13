import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'barChart.dart';
import 'login.dart';
import 'player.dart';


final walkCurrentProvider = StateProvider((ref) => 4800);//[現在の歩数,　目標歩数]
final walkGoalProvider = StateProvider((ref) => 8000);

class Walk extends ConsumerWidget {
  const Walk({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    fetchPlayerData(ref);//プレイヤーデータの取得

    return MaterialApp(
      title: '歩数',
      home: WalkMainPage(),

    );
  }
}

class WalkMainPage extends ConsumerStatefulWidget {
  WalkMainPage({super.key});
  @override
  ConsumerState<WalkMainPage> createState() => WalkState();
}

class WalkState extends ConsumerState<WalkMainPage> {
  late StreamSubscription<StepCount> _subscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();  // パーミッションのリクエストを初期化時に行う
  }

  Future<void> _requestPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _startListening();  // パーミッションが許可された場合にストリームを開始する
    } else {
      print("Permission denied");
    }
  }

  void _startListening() {
    _subscription = Pedometer.stepCountStream.listen(
      _onData,
      onError: _onError,
      cancelOnError: true,
    );
  }

  void _onData(StepCount event) {
    ref.watch(walkCurrentProvider.notifier).state = event.steps;
  }

  void _onError(error) {
    print("Error: $error");
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();  // リソースをクリーンアップ
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text("現在の歩数"),
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
         body: SingleChildScrollView(
             child:Center(
                child: Column(
                 children: <Widget>[
                   Text("目標歩数:${ref.watch(walkGoalProvider)}歩"),
                   BatteryLevelIndicator(),
                   BarChartWidget()

                 ]
               )
             ),
        ),
    );
  }
}

const kColorPurple = Colors.orangeAccent;
const kColorPink = Colors.redAccent;
const kColorIndicatorBegin = kColorPink;
const kColorIndicatorEnd = kColorPurple;
const kElevation = 4.0;

class _BatteryLevelIndicatorPainter extends CustomPainter {
  final double percentage; // バッテリーレベルの割合
  final double textCircleRadius; // 内側に表示される白丸の半径

  _BatteryLevelIndicatorPainter({required this.percentage,required this.textCircleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 1; i < (360 * percentage); i += 5) {
      final per = i / 360.0;

      // 割合（0~1.0）からグラデーション色に変換
      //begin(0)からend(1)までの色の変化の内per(i/360)の色を取得

      final color = ColorTween(
        begin: kColorIndicatorBegin,
        end: kColorIndicatorEnd,
      ).lerp(per)!;

      final paint = Paint()//CustomPaintで円の絵画
        ..color = color
        ..strokeWidth = 4;

      final spaceLen = 16; // 円とゲージ間の長さ
      final lineLen = 24; // ゲージの長さ
      final angle = (2 * pi * per) - (pi / 2); // 0時方向から開始するため-90度ずらす

      // 円の中心座標
      final offset0 = Offset(size.width * 0.5, size.height * 0.5);
      // 線の内側部分の座標
      final offset1 = offset0.translate(
        (textCircleRadius + spaceLen) * cos(angle),
        (textCircleRadius + spaceLen) * sin(angle),
      );
      // 線の外側部分の座標
      final offset2 = offset1.translate(
        lineLen * cos(angle),
        lineLen * sin(angle),
      );

      canvas.drawLine(offset1, offset2, paint);//線を引く
    }
  }

  @override
  //再描画が必要かどうかを返します。 一度描画したら状態が変わらないものを描画する場合は、再描画する必要がありませんので、常にfalse を返す
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BatteryLevelIndicator extends ConsumerWidget {
  final size = 164.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var percentage = ref.watch(walkCurrentProvider)/ref.watch(walkGoalProvider);
    return CustomPaint(
      painter: _BatteryLevelIndicatorPainter(//外側の線を絵画
        percentage: percentage,
        textCircleRadius: size * 0.5,
      ),
      child: Container(
        padding: const EdgeInsets.all(64),
        child: Material(
          color: Colors.white,
          elevation: kElevation,
          borderRadius: BorderRadius.circular(size * 0.5),
          child: Container(
            width: size,
            height: size,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("${ref.watch(walkCurrentProvider)}歩",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 30)),
                  Text(
                    '${double.parse((percentage * 100).toStringAsFixed(1))}%',//小数第一位まで
                    style: TextStyle(color: Colors.blueGrey, fontSize: 25),
                  ),
                ]

              )
            ),
          ),
        ),
      ),
    );
  }
}