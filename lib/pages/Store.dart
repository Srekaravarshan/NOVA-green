import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/Models/StoreModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/CreateProduct.dart';
import 'package:nova_green/pages/Reviews.dart';
import 'package:nova_green/widgets/productCard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Store extends StatefulWidget {
  final String uid;
  final String userId;
  final bool isNetwork;

  const Store(
      {Key key,
      @required this.uid,
      @required this.userId,
      this.isNetwork = false})
      : super(key: key);

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();
  File file;
  String uuid = Uuid().v4();
  bool isImageUploading = false;
  bool isOwner;
  double rating = 3;

  @override
  void initState() {
    super.initState();
    isOwner = widget.uid == widget.userId;
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Photo with Camera"),
                ),
                onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Image from Gallery"),
                ),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Cancel"),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  compressImage(uuid) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$uuid.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile, uuid) async {
    UploadTask uploadTask =
        storageRef.child("photo_$uuid.jpg").putFile(imageFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  addPhoto(StoreModel store, String uid) async {
    setState(() {
      isImageUploading = true;
    });
    await compressImage(uuid);
    String mediaUrl = await uploadImage(file, uuid);
    store.photos.add(mediaUrl);
    await sellersRef.doc(uid).update({'photos': store.photos});
    setState(() {
      uuid = Uuid().v4();
      file = null;
      isImageUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
            stream: sellersRef.doc(widget.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                    child: Center(child: CircularProgressIndicator()));
              }
              StoreModel store = StoreModel.fromDocument(snapshot.data);
              int userCommentedIndex = 0;
              if (store.reviewedUsers.containsKey(_firebaseUser.uid)) {
                for (int i = 0; i < store.ratingMap.length; i++) {
                  if (store.ratingMap.elementAt(i)['userId'] ==
                      _firebaseUser.uid) {
                    break;
                  }
                  userCommentedIndex++;
                }
              }
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //cover image
                      Container(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            image: store.cover == ''
                                ? DecorationImage(
                                    image: AssetImage(
                                        'assets/images/store_ph.jpg'),
                                    alignment: Alignment.center)
                                : DecorationImage(
                                    image: NetworkImage(store.cover),
                                    fit: BoxFit.cover)),
                      ),
                      Container(
                          padding: EdgeInsets.all(25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(store.name,
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              SizedBox(height: 10),
                              Text(store.description,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87)),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    child: ListView.builder(
                                      itemCount: 5,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) => Icon(
                                          Icons.star,
                                          size: 24,
                                          color: index < store.rating
                                              ? Color(0xFF226F54)
                                              : Colors.grey),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '(${store.ratingMap.length})',
                                    style: TextStyle(color: Colors.black45),
                                  )
                                ],
                              )
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Products',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            isOwner
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateProduct(
                                                      storeId: store.userId)));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 13, vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          border: Border.all(
                                              color: Color(0xFF226F54))),
                                      child: Text(
                                        'Add',
                                        style:
                                            TextStyle(color: Color(0xFF226F54)),
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      store.products.isEmpty
                          ? Container()
                          : SingleChildScrollView(
                              child: SizedBox(
                                height: 250,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: store.products.length,
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  itemBuilder: (context, index) {
                                    return StreamBuilder(
                                        stream: productsRef
                                            .doc(store.products
                                                .elementAt(index)['productId'])
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Container();
                                          }
                                          return productCard(
                                              ProductModel.fromDocument(
                                                  snapshot.data),
                                              context,
                                              widget.userId);
                                        });
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(width: 20);
                                  },
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 50,
                        ),
                        child: Text('Photos',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                      ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => Container(
                                height: 250,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 25),
                                decoration: BoxDecoration(
                                    color: Colors.grey[20],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            store.photos.elementAt(index)),
                                        fit: BoxFit.cover)),
                              ),
                          separatorBuilder: (context, index) => SizedBox(
                                height: 20,
                              ),
                          itemCount: store.photos.length),
                      store.photos.isNotEmpty && isOwner
                          ? SizedBox(height: 20)
                          : Container(),
                      isOwner
                          ? (file == null && store.photos.length <= 5)
                              ? InkWell(
                                  onTap: () async {
                                    await selectImage(context);
                                  },
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                        child: Text(
                                      'Add Photo',
                                      style: TextStyle(color: Colors.grey),
                                    )),
                                  ))
                              : Container(
                                  padding: EdgeInsets.all(20),
                                  color: Color(0xFF87C38F),
                                  child: Column(
                                    children: [
                                      Container(
                                          height: 250,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 25),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              image: DecorationImage(
                                                  image: FileImage(file),
                                                  fit: BoxFit.cover))),
                                      SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    file = null;
                                                  });
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  4)),
                                                      border: Border.all(
                                                          color:
                                                              Color(0xFF226F54),
                                                          width: 2)),
                                                  child: Center(
                                                      child: Text('Remove',
                                                          style: TextStyle(
                                                              fontSize: 16))),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: InkWell(
                                                onTap: isImageUploading
                                                    ? null
                                                    : () async {
                                                        await addPhoto(
                                                            store, widget.uid);
                                                      },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  4)),
                                                      color: isImageUploading
                                                          ? Color(0xFF226F54)
                                                              .withOpacity(0.5)
                                                          : Color(0xFF226F54)),
                                                  child: Center(
                                                      child: Text(
                                                          isImageUploading
                                                              ? 'Uploading...'
                                                              : 'Upload',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: isImageUploading
                                                                  ? Colors
                                                                      .white54
                                                                  : Colors
                                                                      .white))),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                          : Container(),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, top: 25, bottom: 20),
                        child: Text('Address',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Color(0xFFF4F0BB),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            children: [
                              Text(store.address,
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(height: 8),
                              Text(
                                store.phoneNumber,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () async {
                                  if (await canLaunch(
                                      'tel:${store.phoneNumber}')) {
                                    await launch('tel:${store.phoneNumber}');
                                  } else {
                                    throw 'Could not launch ${store.phoneNumber}';
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 130,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      border: Border.all(
                                          color: Color(0xFF226F54), width: 2)),
                                  child: Center(
                                    child: Text(
                                      'Call',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, top: 25, bottom: 20),
                        child: Text('Review',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? Container()
                          : Center(
                              child: RatingBar.builder(
                                initialRating: 3,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                // glow: false,
                                updateOnDrag: true,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    this.rating = rating;
                                  });
                                },
                              ),
                            ),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? Container()
                          : SizedBox(height: 15),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  labelText: 'Type something here...',
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                                controller: _reviewController,
                                maxLines: null,
                                minLines: 5,
                                keyboardType: TextInputType.name,
                              ),
                            ),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? Container()
                          : SizedBox(height: 15),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? Container()
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: InkWell(
                                  onTap: () async {
                                    int overallRating = (((store.rating *
                                                    store.ratingMap.length) +
                                                rating) /
                                            (store.ratingMap.length + 1))
                                        .round();
                                    store.ratingMap.add({
                                      'username': _firebaseUser.displayName,
                                      'userId': _firebaseUser.uid,
                                      'rating': rating.round(),
                                      'userProfile': _firebaseUser.photoURL,
                                      'comment': _reviewController.text.trim(),
                                      'timeStamp': DateTime.now()
                                    });
                                    store.reviewedUsers[_firebaseUser.uid] =
                                        true;
                                    await sellersRef.doc(store.userId).update({
                                      'rating': overallRating,
                                      'ratingMap': store.ratingMap,
                                      'reviewedUsers': store.reviewedUsers
                                    });
                                    _reviewController.clear();
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      color: Color(0xFF226F54),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Review',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? SizedBox(height: 25)
                          : SizedBox(height: 50),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              color: Colors.grey[100],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text('Highlighted comment',
                                        style:
                                            TextStyle(color: Colors.black38)),
                                  ),
                                  SizedBox(height: 12),
                                  store.reviewedUsers
                                          .containsKey(_firebaseUser.uid)
                                      ? reviewWidget(store, userCommentedIndex)
                                      : Container(),
                                ],
                              ),
                            )
                          : Container(),
                      store.reviewedUsers.containsKey(_firebaseUser.uid)
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 15,
                            )
                          : Container(),
                      ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) =>
                              reviewWidget(store, index),
                          separatorBuilder: (context, index) => Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Divider(
                                    height: 30,
                                  ),
                                ),
                              ),
                          itemCount: store.ratingMap.length > 5
                              ? 5
                              : store.ratingMap.length),
                      store.ratingMap.length > 5
                          ? SizedBox(height: 50)
                          : Container(),
                      store.ratingMap.length > 5
                          ? Center(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Reviews(
                                              storeId: store.userId,
                                              userId: _firebaseUser.uid)));
                                },
                                child: Container(
                                  height: 40,
                                  width: 130,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      border: Border.all(
                                          color: Color(0xFF226F54), width: 2)),
                                  child: Center(
                                    child: Text(
                                      'See more',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, bottom: 50),
                        child: Text(
                          'NOVA green',
                          style: TextStyle(
                              color: Color(0xFF226F54),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
              top: 40,
              left: 10,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white70, shape: BoxShape.circle),
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.black87)),
              ))
        ],
      ),
    );
  }

  Container reviewWidget(StoreModel store, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              backgroundImage:
                  NetworkImage(store.ratingMap.elementAt(index)['userProfile']),
              radius: 24),
          SizedBox(width: 8),
          Flexible(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.ratingMap.elementAt(index)['username'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 8),
                        store.ratingMap.elementAt(index)['comment'] == ''
                            ? Container()
                            : Container(
                                child: Text(
                                  store.ratingMap.elementAt(index)['comment'],
                                  style: TextStyle(fontSize: 16),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                        store.ratingMap.elementAt(index)['comment'] == ''
                            ? Container()
                            : SizedBox(height: 15),
                      ],
                    ),
                  ),
                  store.ratingMap.elementAt(index)['userId'] == widget.userId
                      ? PopupMenuButton(
                          itemBuilder: (BuildContext bc) => [
                            PopupMenuItem(child: Text("Edit"), value: "Edit"),
                            PopupMenuItem(
                                child: Text("Delete"), value: "Delete"),
                          ],
                          onSelected: (route) async {
                            if (route == 'Delete') {
                              store.ratingMap.removeAt(index);
                              store.reviewedUsers.remove(widget.userId);
                              await sellersRef.doc(store.userId).update({
                                'ratingMap': store.ratingMap,
                                'reviewedUsers': store.reviewedUsers
                              });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    double ratingStar = 3;
                                    _reviewController.text = store.ratingMap
                                        .elementAt(index)['comment'];
                                    return AlertDialog(
                                      title: Text('Edit Review'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: RatingBar.builder(
                                              initialRating: (store.ratingMap
                                                      .elementAt(
                                                          index)['rating'])
                                                  .toDouble(),
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: false,
                                              itemCount: 5,
                                              // glow: false,
                                              updateOnDrag: true,
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                setState(() {
                                                  ratingStar = rating;
                                                  print(ratingStar);
                                                });
                                                print(ratingStar);
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                              hintText:
                                                  'TypeLeave your review here...',
                                            ),
                                            maxLines: null,
                                            controller: _reviewController,
                                            keyboardType: TextInputType.name,
                                            minLines: 5,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel')),
                                        TextButton(
                                            onPressed: () async {
                                              store.ratingMap.elementAt(
                                                      index)['comment'] =
                                                  _reviewController.text.trim();
                                              store.ratingMap.elementAt(
                                                      index)['rating'] =
                                                  ratingStar.toDouble();
                                              await sellersRef
                                                  .doc(store.userId)
                                                  .update({
                                                'ratingMap': store.ratingMap
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text('Update'))
                                      ],
                                    );
                                  });
                            }
                          },
                        )
                      : Container(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 14,
                    child: ListView.builder(
                      itemCount: 5,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, starI) => Icon(Icons.star,
                          size: 14,
                          color:
                              starI < store.ratingMap.elementAt(index)['rating']
                                  ? Color(0xFF226F54)
                                  : Colors.grey),
                    ),
                  ),
                  Text(
                    timeago.format(DateTime.parse(store.ratingMap
                        .elementAt(index)['timeStamp']
                        .toDate()
                        .toString())),
                    style: TextStyle(fontSize: 12, color: Color(0xFF226F54)),
                  )
                ],
              )
            ]),
          ),
        ],
      ),
    );
  }
}
