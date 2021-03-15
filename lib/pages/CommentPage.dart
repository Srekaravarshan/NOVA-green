import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/CommentModel.dart';
import 'package:nova_green/Models/PostModel.dart';
import 'package:nova_green/main.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class CommentPage extends StatefulWidget {
  final PostModel post;
  final User user;

  const CommentPage({Key key, @required this.post, @required this.user})
      : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _commentController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String uuid = Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: commentRef
                    .doc(widget.post.postId)
                    .collection('comments')
                    .orderBy('timeStamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      height: 600,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.all(15),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return commentWidget(CommentModel.fromDocument(
                          snapshot.data.docs.elementAt(index)));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 10);
                    },
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Form(
                  key: _formKey,
                  child: Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                hintText: 'Comment here',
                                filled: true,
                                fillColor: Colors.greenAccent[100],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                            icon: Icon(Icons.send),
                            color: Color(0xFF226F54),
                            onPressed: () async {
                              if (_commentController.text.trim() != '') {
                                String comment = _commentController.text.trim();
                                setState(() {
                                  _commentController.clear();
                                });
                                await commentRef
                                    .doc(widget.post.postId)
                                    .collection('comments')
                                    .doc(uuid)
                                    .set({
                                  'username': widget.user.displayName,
                                  'userId': widget.user.uid,
                                  'postId': widget.post.postId,
                                  'comment': comment,
                                  'userProfile': widget.user.photoURL,
                                  'timeStamp': FieldValue.serverTimestamp()
                                });
                                int commentCount = 0;
                                await postsRef
                                    .doc(widget.post.postId)
                                    .get()
                                    .then((value) {
                                  if (value.exists) {
                                    commentCount = value.data()['commentCount'];
                                  }
                                });
                                await postsRef
                                    .doc(widget.post.postId)
                                    .update({'commentCount': commentCount + 1});
                                print(commentCount);
                                setState(() {
                                  uuid = Uuid().v4();
                                });
                              }
                            })
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget commentWidget(CommentModel comment) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 22, backgroundImage: NetworkImage(comment.userProfile)),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: Text(comment.username,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 10),
                  Container(
                    child: Text(
                        comment.timeStamp == null
                            ? ''
                            : '(${timeago.format(DateTime.parse(comment.timeStamp.toDate().toString()))})',
                        style: TextStyle(fontSize: 11, color: Colors.black45)),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Text(comment.comment, style: TextStyle(fontSize: 15)),
            ],
          )
        ],
      ),
    );
  }
}
