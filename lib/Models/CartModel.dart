import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String _productId;

  CartModel(this._productId);

  factory CartModel.fromDocument(DocumentSnapshot doc) {
    return CartModel(doc['productId']);
  }

  String get productId => _productId;
}
