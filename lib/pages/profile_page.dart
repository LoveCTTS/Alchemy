import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';



class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  File _image;
  FirebaseAuth _firebaseAuth =FirebaseAuth.instance;
  FirebaseUser _user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL = "";
  final picker = ImagePicker();
  bool _hasNetworkImage=false;

  @override
  void initState(){

    super.initState();
    _prepareService();
  }


  void _prepareService() async{
    _user=await _firebaseAuth.currentUser();
    _hasNetworkImage = await hasNetworkImage();
  }

  void _uploadImageToStorage(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    if (image == null) return;

    setState(() {
      _image = image;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의. 사용자의 uid를 이용하여 파일명의 중복 가능성 제거
    StorageReference storageReference =
    _firebaseStorage.ref().child("test/${_user.uid}");

    // 파일 업로드
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);

    // 파일 업로드 완료까지 대기
    await storageUploadTask.onComplete;

    String downloadURL = await storageReference.getDownloadURL();

    // 업로드된 사진의 URL을 페이지에 반영
    setState(() {
      _profileImageURL = downloadURL;
    });
  }

   hasNetworkImage() async{

    StorageReference storageReference =
    _firebaseStorage.ref().child("test/${_user.uid}");
    String downloadURL = await storageReference.getDownloadURL();
    if(downloadURL == null){
      return false;
    }else if(downloadURL != null){
      setState((){
        _profileImageURL = downloadURL;
      });
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _hasNetworkImage? NetworkImage(_profileImageURL):AssetImage("images/다운로드.png")

                    ),
                  ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("Gallery"),
                  onPressed: () {
                    _uploadImageToStorage(ImageSource.gallery);
                  },
                ),
                RaisedButton(
                  child: Text("Camera"),
                  onPressed: () {
                    _uploadImageToStorage(ImageSource.camera);
                  },
                )
              ],
            ),
            SizedBox(height: 23.0),
            ListTile(
              onTap: () {},
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.group),
              title: Text('Groups'),
            ),
            ListTile(
              onTap: () {

              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              onTap: () async {
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        )
    );
  }
}

