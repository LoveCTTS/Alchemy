import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/pages/friends_chat_page.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendTile extends StatefulWidget {

  final String friendChatGroupId;
  final String friendName;

  FriendTile({this.friendChatGroupId, this.friendName});

  @override
  _FriendTileState createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile>{

  User _user;
  String _userName='';
  String appeal='';
  StateSetter _setState;
  bool _hasNetworkImage=false;
  String _profileImageURL='';
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  double distance;
  GeoPoint myGeoPoint;
  bool iHaveNoDistance=false;

  @override
  void initState() {

    super.initState();
    _prepareService();
  }
  @override
  void dispose() {

    _prepareService().dispose();
    super.dispose();

  }
  _prepareService() async{

    _userName=await HelperFunctions.getUserNameSharedPreference();
    _user = FirebaseAuth.instance.currentUser;
    _hasNetworkImage = await hasNetworkImage();
    await DatabaseService(userName:_userName).getLocationFromGPS().then((value){
      setState(() {
        myGeoPoint=value;
      });


    });

  }

  hasNetworkImage() async{

    Reference storageReference =
    _firebaseStorage.ref('user_image/${widget.friendName}' + '[1]');
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
  void _popupChat(BuildContext context) {

    Widget sendButton = FlatButton(
        minWidth: 80,
        child: Text("채팅하기"),
        onPressed:  () async {

          Navigator.of(context).pop();
          //채팅방으로 가기
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              FriendsChatPage(groupId: widget.friendChatGroupId,
                userName: _userName)));
        });
    Widget closeButton = FlatButton(
        minWidth: 80,
        child: Text("닫기"),
        onPressed:  () async {
          Navigator.of(context).pop();
        });

    AlertDialog test = AlertDialog(
        title: Text(widget.friendName),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0)
          )
        ),
        content: Builder(
          builder: (context){
        return Wrap(

            children: <Widget>[
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: _hasNetworkImage? NetworkImage(_profileImageURL):AssetImage("images/default.png")

                  ),
                ),
              ),
              StatefulBuilder(
                builder: (context, setState){
                  _setState = setState;
                  DatabaseService(userName: widget.friendName).getUserAppeal().then((value){
                    _setState(() {
                      appeal = value;
                    });
                  });
                  return Text(appeal);
        }
        ),
              SizedBox(height:10),
              StatefulBuilder(
                  builder: (context, setState){
                    _setState = setState;
                    DatabaseService(userName: widget.friendName).getLocationFromGPS().then((value){
                      _setState(() {
                        distance = Geolocator.distanceBetween(
                            myGeoPoint.latitude, myGeoPoint.longitude,
                            value.latitude, value.longitude);

                      });
                    });
                    return Text("나와의 거리 : 약 " + (distance~/1000).toString() + "km"); // 그냥 / 나눗셈보다는 Dart의 연산자인 ~/을 이용하면 소수점 아래는 자동으로 제거되는 연산자
                  }
              )
        ]
        );
          }
        ),
        actions: <Widget>[
          closeButton,
          sendButton
        ]
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return test;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height:20),
          GestureDetector(
            onTap: (){
              _popupChat(context);

            },
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Container(
                    width: 120,
                    height:180,
                    padding: EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15.0)
                      ),
                      color: Color(0xff9932cc),
                    ),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child:Text("${widget.friendName}", style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Colors.white,
                            fontFamily: "RobotoMono-italic"))
                    )//Gradient Border size 조절
                ),SizedBox(width:20),
                Container(
                    width: 120,
                    height:180,
                    padding: EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(15.0)
                        ),
                      color: Color(0xff9932cc),
                    ),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child:Text("${widget.friendName}", style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Colors.white,
                            fontFamily: "RobotoMono-italic"))
                    )//Gradient Border size 조절
                ),SizedBox(width:20),
                Container(
                    width: 120,
                    height:180,
                    padding: EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(15.0)
                        ),
                      color: Color(0xff9932cc),
                    ),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child:Text("${widget.friendName}", style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Colors.white,
                            fontFamily: "RobotoMono-italic"))
                    )//Gradient Border size 조절
                )

              ])),
          SizedBox(height:10)]
    );
  }
}
