import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/PostModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/CommentPage.dart';

class PostPage extends StatefulWidget {
  final PostModel post;
  final User user;

  const PostPage({Key key, this.post, this.user}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool isLiked;
  bool isSaved;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likedData.containsKey(widget.user.uid);
    isSaved = widget.post.saved.containsKey(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enjoy Reading',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.post.mediaUrl == ''
                  ? Container()
                  : Container(
                      constraints: BoxConstraints(
                        maxHeight: 250,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                              image: NetworkImage(widget.post.mediaUrl),
                              fit: BoxFit.cover)),
                    ),
              widget.post.mediaUrl == '' ? Container() : SizedBox(height: 25),
              Text(
                widget.post.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 25),
              Text(
                widget.post.content,
                style: TextStyle(
                    fontSize: 16,
                    height: 2,
                    color: Colors.black.withOpacity(0.7)),
              ),
              SizedBox(height: 50)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                if (!isLiked) {
                  widget.post.likedData[widget.user.uid] = true;
                  await postsRef
                      .doc(widget.post.postId)
                      .update({'likedData': widget.post.likedData});
                  setState(() {
                    isLiked = true;
                  });
                } else {
                  widget.post.likedData.remove(widget.user.uid);
                  await postsRef
                      .doc(widget.post.postId)
                      .update({'likedData': widget.post.likedData});
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
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Color(0xFF226F54).withOpacity(0.85),
                    ),
                    SizedBox(width: 10),
                    Text('Like',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.7))),
                    SizedBox(width: 6),
                    Text('(${widget.post.likedData.length.toString()})',
                        style: TextStyle(fontSize: 12, color: Colors.black45))
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CommentPage(post: widget.post, user: widget.user)));
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
                    Text('(${widget.post.commentCount.toString()})',
                        style: TextStyle(fontSize: 12, color: Colors.black45))
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                if (!isSaved) {
                  widget.post.saved[widget.user.uid] = true;
                  await postsRef
                      .doc(widget.post.postId)
                      .update({'saved': widget.post.saved});
                  await savedRef
                      .doc(widget.user.uid)
                      .collection('saved')
                      .doc(widget.post.postId)
                      .set({
                    'userId': widget.user.uid,
                    'postId': widget.post.postId,
                    'ownerId': widget.post.userId,
                  });
                  setState(() {
                    isSaved = true;
                  });
                } else {
                  widget.post.saved.remove(widget.user.uid);
                  await postsRef
                      .doc(widget.post.postId)
                      .update({'saved': widget.post.saved});
                  await savedRef
                      .doc(widget.user.uid)
                      .collection('saved')
                      .doc(widget.post.postId)
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
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Color(0xFF226F54).withOpacity(0.85),
                    ),
                    SizedBox(width: 10),
                    Text('Save', style: TextStyle(fontSize: 14))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
