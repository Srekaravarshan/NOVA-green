import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/PostModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/NewNews.dart';
import 'package:nova_green/widgets/BlogCard.dart';
import 'package:provider/provider.dart';

class News extends StatefulWidget {
  final String userId;

  const News({Key key, this.userId = ''}) : super(key: key);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
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
    QuerySnapshot documentList;
    if (widget.userId == '') {
      documentList =
          await postsRef.orderBy('timeStamp', descending: true).limit(10).get();
    } else {
      documentList = await postsRef
          .orderBy('timeStamp', descending: false)
          .where('userId', isEqualTo: widget.userId)
          .limit(10)
          .get();
    }
    documentList.docs.forEach((doc) {
      blogs.add(PostModel.fromDocument(doc));
      blogDocuments.add(doc);
    });
    setState(() {});
    return blogs;
  }

  Future<List<PostModel>> fetchNextMovies() async {
    QuerySnapshot newDocumentList;
    if (widget.userId == '') {
      newDocumentList = await postsRef
          .orderBy('timeStamp', descending: true)
          .startAfterDocument(blogDocuments[blogDocuments.length - 1])
          .limit(10)
          .get();
    } else {
      newDocumentList = await postsRef
          .orderBy('timeStamp', descending: false)
          .where('userId', isEqualTo: widget.userId)
          .startAfterDocument(blogDocuments[blogDocuments.length - 1])
          .limit(10)
          .get();
    }
    newDocumentList.docs.forEach((doc) {
      blogs.add(PostModel.fromDocument(doc));
      blogDocuments.add(doc);
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
                      'No posts from you.\nYou can add new post by pressing bottom left button',
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
