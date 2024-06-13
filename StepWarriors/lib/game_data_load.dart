//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';

class GameDataLoad {
  // 指定されたIDのドキュメントを取得するメソッド
  static Future<T?> getDocument<T>({
    required String collectionPath,
    required String gameID,
    required String dataType,
    required String documentID,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(gameID)
          .collection(dataType)
          .doc(documentID)
          .get();

      if (docSnapshot.exists) {
        return fromMap(docSnapshot.data()!);
      } else {
        return null; // ドキュメントが存在しない場合はnullを返す
      }
    } catch (e) {
      print('Error fetching document: $e');
      return null; // エラー時はnullを返すか、適切なエラー処理を行う
    }
  }

  static Future<T?> getDocumentFromSnapshot<T>({
    required String dataType,
    required String documentID,
    required T Function(Map<String, dynamic>) fromMap,
    required DocumentSnapshot snapshot
  }) async {
    final subCollectionRef = snapshot.reference.collection(dataType);
    final docSnapshot = await subCollectionRef.doc(documentID).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        return fromMap(data);
      }
    }

    return null;
  }

  // コレクション内のすべてのドキュメントを取得するメソッド
  static Future<List<T>> getAllDocuments<T>({
    required String collectionPath,
    required String gameID,
    required String dataType,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(gameID)
          .collection(dataType)
          .get();

      return querySnapshot.docs.map((doc) => fromMap(doc.data()!)).toList();
    } catch (e) {
      print('Error fetching documents: $e');
      return []; // エラー時は空リストを返すか、適切なエラー処理を行う
    }
  }

  static Future<List<T>> getAllDocumentsFromSnapshot<T>({
    required String dataType,
    required T Function(Map<String, dynamic>) fromMap,
    required DocumentSnapshot snapshot
  }) async {
    final List<T> resultList = [];
    final subCollectionRef = snapshot.reference.collection(dataType);
    final querySnapshot = await subCollectionRef.get();

    for (final docshot in querySnapshot.docs){
      final data = docshot.data();
      if(data !=null){
        resultList.add(fromMap(data));
      }
    }
    return resultList;
  }

  static Future<void> saveDocument<T>({
    required String collectionPath,
    required String gameID,
    required String dataType,
    required T data,
    required Map<String, dynamic> Function(T) toMap,
  }) async {
    try {
      final Map<String, dynamic> dataMap = toMap(data);
      final String dataID = dataMap["id"].toString();
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(gameID)
          .collection(dataType)
          .doc(dataID)
          .set(dataMap);
    } catch (e) {
      print('Error saving document: $e');
      // エラー処理
    }
  }
  static Future<void> saveDocuments<T>({
    required String collectionPath,
    required String gameID,
    required String dataType,
    required List<T> dataList,
    required Map<String, dynamic> Function(T) toMap,
  }) async {
    try {
      for (final data in dataList) {
        final Map<String, dynamic> dataMap = toMap(data); // ノードオブジェクトをマップに変換する
        final String dataID = dataMap["id"].toString();

        await FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(gameID)
            .collection(dataType) // ドキュメントを保存するサブコレクションを選択する
            .doc(dataID)
            .set(dataMap);
      }
    } catch (e) {
      print('Error saving documents: $e');
      // エラー処理
    }
  }
}
