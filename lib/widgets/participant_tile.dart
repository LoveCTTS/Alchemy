import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/group_chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/agora_page.dart';
import 'package:vibration/vibration.dart';


class ParticipantTile extends StatefulWidget {//그룹 타일도 한번 실행후 상태 변화가 없기때문에 StatelessWidget 사용

  final String senderName;
  final String participantName;
  final String groupId;

  ParticipantTile({this.senderName,this.participantName,this.groupId});
  @override
  _ParticipantTileState createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {


  bool isChief=false;
  User _user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL='';
  bool hasProfileImage=false;
  bool hasFriendRequest=false;
  bool isMe=false;
  bool hasFriend=false;

  double distance=0.0;
  GeoPoint myGeoPoint;
  List<String> _profileImageURLInPopUp=List<String>(6);
  List<bool> _hasNetworkImageInPopUp = List<bool>.generate(6, (index) => false);
  int imageCount=0;
  bool hasAppeal=false;
  bool hasGPS=false;
  bool hasAge=false;
  String age='';
  String appeal='';


  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    prepareService1();
    prepareSerivce2();


  }

  void prepareService1() async{
    _user = FirebaseAuth.instance.currentUser;
    DatabaseService().isChief(widget.participantName, widget.groupId).then((value){
      setState(() {
        isChief=value;
      });

    });
    hasProfileImage= await _hasProfileImage();
    DatabaseService(userName: widget.participantName).hasFriendRequest(widget.senderName).then((value){
      setState(() {
        hasFriendRequest=value;
      });

    });
    DatabaseService(userName: widget.participantName).hasFriend(widget.senderName).then((value){

      setState(() {
        hasFriend = value;
        print("test : $hasFriend");
      });
    });

  }
  prepareSerivce2() async{
    await DatabaseService(userName:widget.senderName).getLocationFromGPS().then((value){
      //print("my geoPoint : ${value.latitude}/${value.longitude}");
      setState(() {

        myGeoPoint=value;
      });
    });
    await DatabaseService(userName: widget.participantName).getLocationFromGPS().then((value){
      //print("상대방의 경도 : ${value.longitude}");
      //print("상대방의 위도: ${value.latitude}");
      setState(() {
        distance = Geolocator.distanceBetween(
            myGeoPoint.latitude, myGeoPoint.longitude,
            value.latitude, value.longitude);
      });
    });
    DatabaseService(userName: widget.participantName).getUserAppeal().then((value){
      setState(() {
        appeal = value;
        if(appeal!= null){
          hasAppeal=true;
        }else{
          hasAppeal=false;
        }
      });
    });
    DatabaseService(userName: widget.participantName).getUserAge().then((value){
      setState(() {
        age = value;
        if(age!= null){
          hasAge=true;
        }else{
          hasAge=false;
        }
      });
    });
    for(int i=0;i<6;i++) {
      _hasNetworkImageInPopUp[i] =await hasNetworkImageInPopUp(i);
    }

  }
  _hasProfileImage() async{

    Reference storageReference =
    _firebaseStorage.ref('user_image/${widget.participantName}/${widget.participantName}[0]');
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
  Future<bool> hasNetworkImageInPopUp(int number) async{

    Reference storageReference =
    _firebaseStorage.ref("user_image/${widget.participantName}/${widget.participantName}[$number]");

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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if(widget.senderName!=widget.participantName){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(

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
                      Positioned(left:10,bottom: 80,child:Row(children:[Text(widget.participantName,style: TextStyle(color: Colors.white)),
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
            },
          );
          }
        },
        child:
        Padding(

          padding: EdgeInsets.only(left:15,bottom: 20),
            child:SizedBox( //Card size 조절하기위한 SizedBox
                height:50.0,
                child: Row(children: [
                      Container(
                          width:50,
                          height:50,
                          child: isChief? Align(alignment: Alignment.bottomRight,child:Icon(Icons.military_tech_rounded, color: Colors.red)): null,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: hasProfileImage? NetworkImage(_profileImageURL):AssetImage("images/default.png")
                              )
                          )
                      ),
                        SizedBox(width:15),
                        Container( width: 100,child:Text(widget.participantName,style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold))),
                        SizedBox(width: 10),
                        widget.senderName!=widget.participantName?IconButton(
                          onPressed: () async{
                              await DatabaseService(uid:_user.uid).updateRequest(widget.participantName,widget.senderName);
                              await DatabaseService(userName: widget.participantName).hasFriendRequest(widget.senderName).then((value){
                                setState(() {
                                  hasFriendRequest = value;
                                });
                              });
                          },
                            icon: hasFriendRequest?
                            Container(width:150,child:Text("요청됨",style: TextStyle(color:Colors.purpleAccent,fontSize: 11)))
                            :
                            hasFriend? SizedBox.shrink():Icon(Icons.person_add_rounded, color: Colors.white, size: 30)

                        )
                            : SizedBox.shrink()


                ],




                )

            ))

    );



  }
}