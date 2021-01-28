import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/pages/friends_chat_page.dart';
import '../pages/group_chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendTile1 extends StatefulWidget {

  final String friendChatGroupId;
  final String friendName;

  FriendTile1({this.friendChatGroupId, this.friendName});

  @override
  _FriendTileState createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile1>{

  User _user;
  String _userName='';
  String appeal='';
  String age='';
  StateSetter _setState;
  bool _hasNetworkImage=false;
  String _profileImageURL='';
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  double distance=0.0;
  GeoPoint myGeoPoint;
  bool iHaveNoDistance=false;
  List<String> _profileImageURLInPopUp=List<String>(6);
  List<bool> _hasNetworkImageInPopUp = List<bool>.generate(6, (index) => false);
  int imageCount=0;
  bool hasAppeal=false;
  bool hasGPS=false;
  bool hasAge=false;


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

    await DatabaseService(userName:_userName).getLocationFromGPS().then((value){
      //print("my geoPoint : ${value.latitude}/${value.longitude}");
      setState(() {

        myGeoPoint=value;
      });
    });
    await DatabaseService(userName: widget.friendName).getLocationFromGPS().then((value){
      //print("상대방의 경도 : ${value.longitude}");
      //print("상대방의 위도: ${value.latitude}");
      setState(() {
        distance = Geolocator.distanceBetween(
            myGeoPoint.latitude, myGeoPoint.longitude,
            value.latitude, value.longitude);
      });
      });
    DatabaseService(userName: widget.friendName).getUserAppeal().then((value){
      setState(() {
        appeal = value;
        if(appeal!= null){
          hasAppeal=true;
        }else{
          hasAppeal=false;
        }
      });
    });
    DatabaseService(userName: widget.friendName).getUserAge().then((value){
      setState(() {
        age = value;
        if(age!= null){
          hasAge=true;
        }else{
          hasAge=false;
        }
      });
    });



    _user = FirebaseAuth.instance.currentUser;
    _hasNetworkImage = await hasNetworkImage();

    for(int i=0;i<6;i++) {
      _hasNetworkImageInPopUp[i] =await hasNetworkImageInPopUp(i);
    }



  }
  Future<bool> hasNetworkImageInPopUp(int number) async{

    Reference storageReference =
    _firebaseStorage.ref("user_image/${widget.friendName}/${widget.friendName}[$number]");

    String downloadURL = await storageReference.getDownloadURL();
    if(downloadURL == null){
      return false;
    }else if(downloadURL != null){
      setState((){
        _profileImageURLInPopUp[number] = downloadURL;
        imageCount += 1;
      });
      return true;
    }
    return false;
  }

  hasNetworkImage() async{

    Reference storageReference =
    _firebaseStorage.ref('user_image/${widget.friendName}/${widget.friendName}[0]');
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

    AlertDialog test = AlertDialog(

        backgroundColor: Color(0xff212121),
        contentPadding: EdgeInsets.all(0), //이 특징이없으면 content를 넣어놨을때 다른 패딩공간이 기본적으로 있게되어, 이미지가 Alertdialog를 꽉채우지않는다.
        insetPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 80), //Alertdialog 창크기조절시 insetPadding으로 조절하면됨.
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0)
          )
        ),
        content: Stack(
            children: [
              Container(
                width:400,
                  height:525,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _hasNetworkImageInPopUp[0]?imageCount: 1,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {

                        return Container(
                          height: 300,
                          width: 350,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(width:1.0,color: Colors.purple),
                            borderRadius: BorderRadius.all(
                                Radius.circular(20)
                            ),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: _hasNetworkImageInPopUp[index]? NetworkImage(_profileImageURLInPopUp[index]):AssetImage("images/default2.png")
                            ),
                          ),
                        );
                },
              )),
              Positioned(left:10,bottom: 80,child:Row(children:[Text(widget.friendName,style: TextStyle(color: Colors.white)),
                hasAge? Text(" ($age)",style: TextStyle(color: Colors.white)) : SizedBox.shrink()])),
              Positioned(left:10,bottom: 60,child: hasAppeal? Text(appeal,style: TextStyle(color: Colors.white)) : SizedBox.shrink()),
              Positioned(left:10, bottom:40,
                  child: Text("나와의 거리 : 약 " + (distance~/1000).toString() + "km",style: TextStyle(color:Colors.white))
                /*StatefulBuilder(
                      builder: (context, setState) {
                        _setState = setState;
                        DatabaseService(userName: widget.friendName).getLocationFromGPS().then((value){
                          print("상대방의 경도 : ${value.longitude}");
                          print("상대방의 위도: ${value.latitude}");
                          _setState(() {
                            distance = Geolocator.distanceBetween(
                                myGeoPoint.latitude, myGeoPoint.longitude,
                                value.latitude, value.longitude);
                            *//*if(distance != null){
                            hasGPS=true;
                            }else if(distance == null){
                            hasGPS=false;
                            }*//*
                          });
                        });
                        return Text("나와의 거리 : 약 " + (distance~/1000).toString() + "km",style: TextStyle(color:Colors.white));
                        // 그냥 / 나눗셈보다는 Dart의 연산자인 ~/을 이용하면 소수점 아래는 자동으로 제거되는 연산자
                        //GPS 로드 속도때문에 0km로 로드되는 버그있음.
                      }
                  )*/

              )

              ]),


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
    return GestureDetector(
            onTap: (){
              _popupChat(context);
            }, child:
                  Container(
                        margin: const EdgeInsets.only(left:20,top:20,right:10),
                        width:130,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(width:1.5),
                          gradient: LinearGradient(
                              colors: [
                                Color(0xff212121),
                                Color(0xff9932cc)
                              ]
                          ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            )
                        ),
                        child:Padding(
                            padding: const EdgeInsets.all(1.5),
                            child:Container(
                              width:120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: _hasNetworkImage? NetworkImage(_profileImageURL):AssetImage("images/default.png"),
                                    ),
                                  ),
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child:Text("${widget.friendName}", style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Colors.white,
                                          fontFamily: "RobotoMono-italic"))
                                  )//Gradient Border size 조절
                ))),
              );

  }
}
