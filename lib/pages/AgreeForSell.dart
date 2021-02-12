import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_green/Models/StoreModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/BusinessForm.dart';
import 'package:nova_green/pages/Store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Agree extends StatefulWidget {
  @override
  _AgreeState createState() => _AgreeState();
}

class _AgreeState extends State<Agree> {
  File file;
  String uuid = Uuid().v4();
  bool isImageUploading = false;

  Future<bool> checkDocExists(String userId) async {
    bool exists = false;
    try {
      await sellersRef.doc(userId).get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      print(exists);
      return exists;
    } catch (e) {
      print(e.toString());
      return false;
    }
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
      body: FutureBuilder<bool>(
          future: checkDocExists(_firebaseUser.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                  child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.data) {
              return Store(
                uid: _firebaseUser.uid,
                userId: _firebaseUser.uid,
              );
            } else {
              return SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 80),
                            Container(
                              height: 400,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  color: Color(0xFF226F54),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/product_bg.png'),
                                      fit: BoxFit.cover),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sell your Products across the World',
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 25),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BusinessForm()));
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        color: Color(0xFFF4F0BB),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Start selling',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: 20,
                        left: 10,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: Colors.white38,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.black87)),
                        ))
                  ],
                ),
              );
            }
          }),
    );
  }
}
