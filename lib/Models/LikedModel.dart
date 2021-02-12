import 'package:cloud_firestore/cloud_firestore.dart';

class LikedModel {
  final String _productId;

  LikedModel(this._productId);

  factory LikedModel.fromDocument(DocumentSnapshot doc) {
    return LikedModel(doc['productId']);
  }

  String get productId => _productId;
}
