import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String _comment;
  final String _postId;
  final Timestamp _timeStamp;
  final String _userId;
  final String _userProfile;
  final String _username;

  CommentModel(this._comment, this._postId, this._timeStamp, this._userId,
      this._userProfile, this._username);

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    return CommentModel(doc['comment'], doc['postId'], doc['timeStamp'],
        doc['userId'], doc['userProfile'], doc['username']);
  }

  String get username => _username;

  String get userProfile => _userProfile;

  String get userId => _userId;

  Timestamp get timeStamp => _timeStamp;

  String get postId => _postId;

  String get comment => _comment;
}
