import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String _name;
  final String _description;
  final String _address;
  final String _phoneNumber;
  final String _cover;
  final List _ratingMap;
  final int _rating;
  final List _products;
  final List _photos;
  final String _userId;
  final Map _reviewedUsers;

  StoreModel(
      this._name,
      this._description,
      this._address,
      this._phoneNumber,
      this._cover,
      this._ratingMap,
      this._rating,
      this._products,
      this._photos,
      this._userId,
      this._reviewedUsers);

  factory StoreModel.fromDocument(DocumentSnapshot doc) {
    return StoreModel(
      doc['name'],
      doc['description'],
      doc['address'],
      doc['phoneNumber'],
      doc['cover'],
      doc['ratingMap'],
      doc['rating'],
      doc['products'],
      doc['photos'],
      doc['userId'],
      doc['reviewedUsers'],
    );
  }

  List get photos => _photos;

  List get products => _products;

  int get rating => _rating;

  List get ratingMap => _ratingMap;

  String get phoneNumber => _phoneNumber;

  String get cover => _cover;

  String get address => _address;

  String get description => _description;

  String get name => _name;

  String get userId => _userId;

  Map get reviewedUsers => _reviewedUsers;
}
