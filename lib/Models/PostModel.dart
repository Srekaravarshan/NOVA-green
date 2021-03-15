import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String _content;
  final Map _likedData;
  final String _mediaUrl;
  final String _postId;
  final Timestamp _timeStamp;
  final String _title;
  final String _userId;
  final String _userProfile;
  final String _username;
  final Map _saved;
  final int _commentCount;

  PostModel(
      this._content,
      this._likedData,
      this._mediaUrl,
      this._postId,
      this._timeStamp,
      this._title,
      this._userId,
      this._userProfile,
      this._username,
      this._saved,
      this._commentCount);

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    PostModel post;
    try {
      post = PostModel(
        doc['content'],
        doc['likedData'],
        doc['mediaUrl'],
        doc['postId'],
        doc['timeStamp'],
        doc['title'],
        doc['userId'],
        doc['userProfile'],
        doc['username'],
        doc['saved'],
        doc['commentCount'],
      );
    } catch (e) {
      print(e);
    }
    return post;
  }

  String get username => _username;

  String get userProfile => _userProfile;

  String get userId => _userId;

  String get title => _title;

  Timestamp get timeStamp => _timeStamp;

  String get postId => _postId;

  String get mediaUrl => _mediaUrl;

  Map get likedData => _likedData;

  String get content => _content;

  Map get saved => _saved;

  int get commentCount => _commentCount;
}
