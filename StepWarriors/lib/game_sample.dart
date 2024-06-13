import 'package:bonfire/bonfire.dart';
import 'package:flame/game.dart';
/// サンプルゲーム
class Sample extends FlameGame {
  @override
  Future<void> onLoad() async {
    // 文字列を配置する
    await add(
      PositionComponent(
        children: [TextComponent(text: 'Hello, World!', anchor: Anchor.center)],
        position: Vector2(size.x * 0.5, size.y * 0.5),
        anchor: Anchor.center,
      ),
    );
    super.onLoad();
  }
}