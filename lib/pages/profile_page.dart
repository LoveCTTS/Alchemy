import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  File _image;
  final picker = ImagePicker();

  Future getImageFromCamera() async{

    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState((){
      if(pickedFile != null){

        _image= File(pickedFile.path);
      } else{
        print('No image selected');
      }

    });
  }
  Future getImageFromGallery() async{

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState((){
      if(pickedFile != null){

        _image= File(pickedFile.path);
      } else{
        print('No image selected');
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[

            GestureDetector(
              onTap: (){

                getImageFromGallery();
              },
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _image==null? AssetImage("images/다운로드.png"):FileImage(_image),
                      fit: BoxFit.fill
                    ),
                  ),
            )),
            /*GestureDetector(
                onTap: (){
                  getImageFromGallery();
                },
                child: CircleAvatar(
                    child:Image.file(_image),
                    radius: 60.0
                )),*/
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

