import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String _mediaUrl;
  final String _productType;
  final String _name;
  final String _price;
  final String _weight;
  final String _description;
  final String _temperature;
  final String _shade;
  final String _waterLevel;
  final String _plantType;
  final List _photos;
  final String _productId;
  final String _storeId;
  final List _ratingMap;
  final int _rating;
  final String _storeName;
  final String _category;
  final String _nameFS;
  final Map _reviewedUsers;

  ProductModel(
      this._mediaUrl,
      this._productType,
      this._name,
      this._price,
      this._weight,
      this._description,
      this._temperature,
      this._shade,
      this._waterLevel,
      this._plantType,
      this._photos,
      this._productId,
      this._storeId,
      this._ratingMap,
      this._rating,
      this._storeName,
      this._category,
      this._nameFS,
      this._reviewedUsers);

  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    return ProductModel(
      doc['mediaUrl'],
      doc['productType'],
      doc['name'],
      doc['price'],
      doc['weight'],
      doc['description'],
      doc['temperature'],
      doc['shade'],
      doc['waterLevel'],
      doc['plantType'],
      doc['photos'],
      doc['productId'],
      doc['storeId'],
      doc['ratingMap'],
      doc['rating'],
      doc['storeName'],
      doc['category'],
      doc['nameFS'],
      doc['reviewedUsers'],
    );
  }

  factory ProductModel.fromMap(Map doc) {
    return ProductModel(
      doc['mediaUrl'],
      doc['productType'],
      doc['name'],
      doc['price'],
      doc['weight'],
      doc['description'],
      doc['temperature'],
      doc['shade'],
      doc['waterLevel'],
      doc['plantType'],
      doc['photos'],
      doc['productId'],
      doc['storeId'],
      doc['ratingMap'],
      doc['rating'],
      doc['storeName'],
      doc['category'],
      doc['nameFS'],
      doc['reviewedUsers'],
    );
  }

  int get rating => _rating;

  List get ratingMap => _ratingMap;

  String get storeId => _storeId;

  String get productId => _productId;

  List get photos => _photos;

  String get plantType => _plantType;

  String get waterLevel => _waterLevel;

  String get shade => _shade;

  String get temperature => _temperature;

  String get description => _description;

  String get weight => _weight;

  String get price => _price;

  String get name => _name;

  String get productType => _productType;

  String get mediaUrl => _mediaUrl;

  String get storeName => _storeName;

  String get category => _category;

  String get nameFS => _nameFS;

  Map get reviewedUsers => _reviewedUsers;
}
