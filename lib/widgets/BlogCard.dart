import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/PostModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/CommentPage.dart';
import 'package:nova_green/pages/PostPage.dart';
import 'package:timeago/timeago.dart' as timeago;

class BlogCard extends StatefulWidget {
  final String postId;
  final User user;

  const BlogCard({Key key, @required this.postId, @required this.user})
      : super(key: key);

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool isLiked;
  bool isSaved;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: postsRef.doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: 600,
              color: Colors.grey[200],
            );
          }
          PostModel post = PostModel.fromDocument(snapshot.data);
          isLiked = post.likedData.containsKey(widget.user.uid);
          isSaved = post.saved.containsKey(widget.user.uid);
          return InkWell(
            child: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        CircleAvatar(
                            backgroundImage: NetworkImage(post.userProfile),
                            radius: 20),
                        SizedBox(width: 10),
                        Text(post.username,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  post.mediaUrl == ''
                      ? Container()
                      : Container(
                          constraints: BoxConstraints(
                            maxHeight: 250,
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              image: DecorationImage(
                                  image: NetworkImage(post.mediaUrl),
                                  fit: BoxFit.cover)),
                        ),
                  post.mediaUrl == '' ? Container() : SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PostPage(post: post, user: widget.user)));
                      setState(() {});
                    },
                    child: post.mediaUrl == ''
                        ? Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.clip,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  post.content,
                                  style: TextStyle(
                                      fontSize: 14,
                                      height: 1.75,
                                      color: Colors.black.withOpacity(0.7)),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 10,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Read more...',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.blue),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.clip,
                              ),
                              SizedBox(height: 10),
                              Text(
                                post.content,
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 1.75,
                                    color: Colors.black.withOpacity(0.7)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Read more...',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: 6),
                  Divider(
                    height: 25,
                    color: Colors.black12,
                  ),
                  Text(
                    timeago.format(
                        DateTime.parse(post.timeStamp.toDate().toString())),
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          if (!isLiked) {
                            post.likedData[widget.user.uid] = true;
                            await postsRef
                                .doc(post.postId)
                                .update({'likedData': post.likedData});
                            setState(() {
                              isLiked = true;
                            });
                          } else {
                            post.likedData.remove(widget.user.uid);
                            await postsRef
                                .doc(post.postId)
                                .update({'likedData': post.likedData});
                            setState(() {
                              isLiked = false;
                            });
                          }
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Color(0xFF226F54).withOpacity(0.85),
                              ),
                              SizedBox(width: 10),
                              Text('Like',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.7))),
                              SizedBox(width: 6),
                              Text('(${post.likedData.length.toString()})',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black45))
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentPage(
                                      post: post, user: widget.user)));
                          setState(() {});
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat,
                                color: Color(0xFF226F54).withOpacity(0.85),
                              ),
                              SizedBox(width: 10),
                              Text('Comment', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 6),
                              Text('(${post.commentCount.toString()})',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black45))
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          if (!isSaved) {
                            post.saved[widget.user.uid] = true;
                            await postsRef
                                .doc(post.postId)
                                .update({'saved': post.saved});
                            await savedRef
                                .doc(widget.user.uid)
                                .collection('saved')
                                .doc(post.postId)
                                .set({
                              'userId': widget.user.uid,
                              'postId': post.postId,
                              'ownerId': post.userId,
                              'timeStamp': FieldValue.serverTimestamp(),
                              'content': post.content,
                              'likedData': post.likedData,
                              'mediaUrl': post.mediaUrl,
                              'title': post.title,
                              'userProfile': post.userProfile,
                              'username': post.username,
                              'saved': post.saved,
                              'commentCount': post.commentCount,
                            });
                            setState(() {
                              isSaved = true;
                            });
                          } else {
                            post.saved.remove(widget.user.uid);
                            await postsRef
                                .doc(post.postId)
                                .update({'saved': post.saved});
                            await savedRef
                                .doc(widget.user.uid)
                                .collection('saved')
                                .doc(post.postId)
                                .delete();
                            setState(() {
                              isSaved = false;
                            });
                          }
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Color(0xFF226F54).withOpacity(0.85),
                              ),
                              SizedBox(width: 10),
                              Text('Save', style: TextStyle(fontSize: 14))
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
