import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/services/auth_service.dart';

import 'authenticate_page.dart';
import 'group_page.dart';



class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final AuthService _auth = AuthService();
  File _image;
  FirebaseAuth _firebaseAuth =FirebaseAuth.instance;
  FirebaseUser _user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL = "";
  final picker = ImagePicker();
  bool _hasNetworkImage=false;
  String _userName='';
  StorageReference _storageReference;

  @override
  void initState(){

    super.initState();
    _prepareService();
  }


  void _prepareService() async{
    _user=await _firebaseAuth.currentUser();
    _hasNetworkImage = await hasNetworkImage();
    _userName=await HelperFunctions.getUserNameSharedPreference();
  }

  void _deleteImageFromStorage() async{

    StorageReference _storageReference = _firebaseStorage.ref().child("users/${_user.uid}");
    String downloadURL = await _storageReference.getDownloadURL();

    setState(() {
      _profileImageURL = downloadURL;
    });

    _storageReference = await FirebaseStorage.instance.getReferenceFromUrl(_profileImageURL);
    _storageReference.delete();

  }
  void _uploadImageToStorage(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    if (image == null) return;

    setState(() {
      _image = image;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의. 사용자의 uid를 이용하여 파일명의 중복 가능성 제거
    StorageReference storageReference =
    _firebaseStorage.ref().child("users/${_user.uid}");

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
    _firebaseStorage.ref().child("users/${_user.uid}");
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

  void _popupEdit(BuildContext context) {


    AlertDialog edit = AlertDialog(
        content: Container(
            width: 250,
            height: 150,
            child:Column(children: [

              TextButton(
                onPressed: (){

                  _uploadImageToStorage(ImageSource.gallery);
                },
                  child: Text("업로드")),
              TextButton(

                  onPressed: (){

                    _deleteImageFromStorage();
                  },

                  child: Text("삭제하기")),
            ]
            )
        ) ,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return edit;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[


            Row(
                children: [
                  GestureDetector(
                    onTap: (){

                      _popupEdit(context);
                    },
                      child: Container(
              height: 80,
              width: 80,
              child: Align(alignment: Alignment.center,child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Colors.red))),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                    image: _hasNetworkImage? NetworkImage(_profileImageURL):AssetImage("images/default.png")

                ),
              ),
            )),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: AssetImage("images/default.png")

                  ),
                ),
              ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: AssetImage("images/default.png")

                  ),
                ),
              ),
              ]),
            Row(
                children: [
                  Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                    image: AssetImage("images/default.png")

                ),
              ),
            ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: AssetImage("images/default.png")

                  ),
                ),
              ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: AssetImage("images/default.png")

                  ),
                ),
              ),
            ]),
            SizedBox(height: 23.0),

            Container(
                child: TextField(

                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: '자기 소개 ',
                    )

            )),
            SizedBox(height:30),
            Container(
                child: TextField(

                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: '관심 해시태그 ',
                    )

                )),
            SizedBox(height:30),
            Container(
                child: TextField(

                    decoration: InputDecoration(

                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: '거주지 ',
                    )

                )),

            ListTile(
              onTap: () async {

                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthenticatePage()), (Route<dynamic> route) => false);
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

