import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/PostModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/NewNews.dart';
import 'package:nova_green/widgets/BlogCard.dart';
import 'package:provider/provider.dart';

class SavedBlogs extends StatefulWidget {
  final String userId;

  const SavedBlogs({Key key, this.userId = ''}) : super(key: key);

  @override
  _SavedBlogsState createState() => _SavedBlogsState();
}

class _SavedBlogsState extends State<SavedBlogs> {
  ScrollController scrollController = ScrollController();
  List<PostModel> blogs = [];
  List<DocumentSnapshot> blogDocuments = [];
  Future fetch;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    setState(() {
      fetch = fetchFirstList();
    });
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchNextMovies();
    }
  }

  Future<List<PostModel>> fetchFirstList() async {
    QuerySnapshot documentList = await savedRef
        .doc(widget.userId)
        .collection('saved')
        .orderBy('timeStamp', descending: false)
        .limit(10)
        .get();
    documentList.docs.forEach((docA) async {
      print('i am in ');
      PostModel post = PostModel.fromDocument(docA);
      // DocumentSnapshot doc =
      await postsRef.doc(post.postId).get().then((doc) async {
        if (doc.exists) {
          print('exists');
          setState(() {
            blogs.add(PostModel.fromDocument(doc));
            blogDocuments.add(doc);
          });
          print('size ${blogs.length}');
        } else {
          await savedRef
              .doc(widget.userId)
              .collection('saved')
              .doc(post.postId)
              .delete();
        }
      });
      // return doc;
    });
    return blogs;
  }

  Future<List<PostModel>> fetchNextMovies() async {
    QuerySnapshot newDocumentList = await savedRef
        .doc(widget.userId)
        .collection('saved')
        .startAfterDocument(blogDocuments[blogDocuments.length - 1])
        .orderBy('timeStamp', descending: false)
        .limit(10)
        .get();
    newDocumentList.docs.forEach((docA) async {
      PostModel post = PostModel.fromDocument(docA);
      DocumentSnapshot doc =
          await postsRef.doc(post.postId).get().then((doc) async {
        if (doc.exists) {
          blogs.add(PostModel.fromDocument(doc));
          blogDocuments.add(doc);
          return doc;
        } else {
          await savedRef
              .doc(widget.userId)
              .collection('saved')
              .doc(post.postId)
              .delete();
          return null;
        }
      });
      return doc;
    });
    setState(() {});
    return blogs;
  }

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blog posts',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (context) => NewNews()));
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: fetch,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 800,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return blogs.length == 0
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Center(
                        child: Text(
                      'There is no saved post',
                      textAlign: TextAlign.center,
                    )))
                : SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return BlogCard(
                                  postId: blogs[index].postId,
                                  user: _firebaseUser);
                            },
                            separatorBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 25.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: 5,
                                          width: 5,
                                          color: Colors.black),
                                      SizedBox(width: 20),
                                      Container(
                                          height: 5,
                                          width: 5,
                                          color: Colors.black),
                                      SizedBox(width: 20),
                                      Container(
                                          height: 5,
                                          width: 5,
                                          color: Colors.black),
                                    ],
                                  ),
                                ),
                            itemCount: blogs.length),
                        SizedBox(height: 60)
                      ],
                    ));
          }),
    );
  }
}
