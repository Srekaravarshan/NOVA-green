import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final List _addresses;
  final String _userId;

  AddressModel(this._addresses, this._userId);

  factory AddressModel.fromDocument(DocumentSnapshot doc) {
    return AddressModel(doc['addresses'], doc['userId']);
  }

  String get userId => _userId;

  List get addresses => _addresses;
}
