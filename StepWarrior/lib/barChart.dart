import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BarChartWidget extends ConsumerWidget {

  // 棒グラフの棒の横幅
  static const double barWidth = 20.0;
  // グラフタイトルのラベル書式
  final TextStyle _labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w800);
  // ダミーデータ
  final blogLog = <double>[1100, 5000, 8000, 6890, 300, 4000, 5200];

  final barcolor = Colors.orange;
  BarChartWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(
            maxY: 10000, //Y軸の最大値を指定
            // 棒グラフの位置
            alignment: BarChartAlignment.spaceEvenly,

            // グラフタイトルのパラメータ
            titlesData: FlTitlesData(
              show: true,
              //右タイトル
              rightTitles:AxisTitles(
                  sideTitles: SideTitles(showTitles: false)
              ),
              //上タイトル
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              //下タイトル
              bottomTitles: AxisTitles(
                axisNameWidget: Text('曜日',style: _labelStyle,),
                axisNameSize: 25,
                sideTitles: SideTitles(
                  showTitles: true,
                ),
              ),
              // 左タイトル
              leftTitles: AxisTitles(
                axisNameWidget: Container(
                    alignment: Alignment.topCenter,
                    child: Text('歩数',style: _labelStyle,)),
                axisNameSize: 25,
                sideTitles: SideTitles(
                  showTitles: true,
                ),
              ),
            ),

            // 外枠表の線を表示/非表示
            borderData: FlBorderData(
                border: const Border(
                  top: BorderSide.none,
                  right: BorderSide.none,
                  left: BorderSide(width: 1),
                  bottom: BorderSide(width: 1),
                )),


            // barGroups: 棒グラフのグループを表す
            // BarChartGroupData: 棒グラフの1つのグループを表す
            // X : 横軸
            // barRods: 棒グラフのデータを含むBarRodクラスのリスト
            // BarChartRodData
            // toY : 高さ
            // width : 棒の幅
            barGroups: [
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(toY: blogLog[0], width: barWidth, color: barcolor),
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(toY: blogLog[1], width: barWidth, color: barcolor),
              ]),
              BarChartGroupData(x: 3, barRods: [
                BarChartRodData(toY: blogLog[2], width: barWidth, color: barcolor),
              ]),
              BarChartGroupData(x: 4, barRods: [
                BarChartRodData(toY: blogLog[3], width: barWidth, color: barcolor),
              ]),
              BarChartGroupData(x: 5, barRods: [
                BarChartRodData(toY: blogLog[4], width: barWidth, color: barcolor),
              ]),
              BarChartGroupData(x: 6, barRods: [
                BarChartRodData(toY: blogLog[5], width: barWidth, color: barcolor),
              ]),
              BarChartGroupData(x: 7, barRods: [
                BarChartRodData(toY: blogLog[6], width: barWidth, color: barcolor),
              ]),
            ]),
      ),
    );
  }
}