import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_green/Extension.dart';
import 'package:nova_green/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewNews extends StatefulWidget {
  @override
  _NewNewsState createState() => _NewNewsState();
}

class _NewNewsState extends State<NewNews> {
  File file;
  bool isUploading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String uuid = Uuid().v4();

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

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage(userId) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$userId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$uuid.jpg").putFile(imageFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({
    @required mediaUrl,
    @required title,
    @required content,
    @required userId,
    @required username,
    @required userProfile,
  }) {
    postsRef.doc(uuid).set({
      'userId': userId,
      'title': title,
      'content': content,
      'postId': uuid,
      'mediaUrl': mediaUrl,
      'timeStamp': FieldValue.serverTimestamp(),
      'likedData': {},
      'username': username,
      'userProfile': userProfile,
      'saved': {},
      'commentCount': 0
    });
  }

  handleSubmit(User user) async {
    setState(() {
      isUploading = true;
    });
    if (file != null) {
      await compressImage(user.uid);
    }
    String mediaUrl = file == null ? '' : await uploadImage(file);
    await createPostInFirestore(
        mediaUrl: mediaUrl,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        userId: user.uid,
        username: user.displayName,
        userProfile: user.photoURL);
    _titleController.clear();
    _contentController.clear();
    setState(() {
      file = null;
      isUploading = false;
      uuid = Uuid().v4();
    });
  }

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'New blog',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              file == null
                  ? Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[200],
                      child: InkWell(
                        onTap: () => selectImage(context),
                        child: Container(
                          height: 45,
                          width: 250,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Text('Upload cover photo',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white))
                              .center(),
                        ),
                      ).center(),
                    )
                  : Stack(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.width),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: FileImage(file), fit: BoxFit.cover)),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 15,
                          child: InkWell(
                            onTap: () => clearImage(),
                            child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Icon(Icons.delete, color: Colors.red)),
                          ),
                        )
                      ],
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Colors.grey[100],
                          filled: true,
                          labelText: 'Title*',
                          isDense: true),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter tile of blog';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Colors.grey[100],
                          filled: true,
                          labelText: 'Content',
                          isDense: true),
                      maxLines: null,
                      minLines: 10,
                    ),
                    SizedBox(height: 60),
                    InkWell(
                      onTap: (!isUploading)
                          ? () async {
                              if (_formKey.currentState.validate()) {
                                await handleSubmit(_firebaseUser);
                                Navigator.pop(context);
                              }
                            }
                          : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            color: (!isUploading)
                                ? Color(0xFF226F54)
                                : Color(0xFF226F54).withOpacity(0.5),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10)
                            ]),
                        child: Text(
                          isUploading ? 'Publishing...' : 'Publish blog',
                          style: TextStyle(
                              color:
                                  isUploading ? Colors.white60 : Colors.white,
                              fontSize: 16),
                        ).center(),
                      ),
                    ),
                    SizedBox(height: 60)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
