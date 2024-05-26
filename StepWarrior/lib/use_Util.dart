import 'package:firebase_auth/firebase_auth.dart';

class UserUtils {
  String getCurrentUserUid() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid ?? ""; // currentUser?.uid が null の場合は空文字列を返す
  }
}
