import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedometer Demo',
      home: PedometerPage(),
    );
  }
}

class PedometerPage extends StatefulWidget {
  @override
  _PedometerPageState createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  int _stepCount = 0;
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
    setState(() {
      _stepCount = event.steps;  // ステートを更新してUIをリフレッシュ
    });
  }

  void _onError(error) {
    print("Error: $error");
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();  // リソースをクリーンアップ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedometer Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '歩数:',
            ),
            Text(
              '$_stepCount',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
