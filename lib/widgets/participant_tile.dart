import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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


  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    prepareService();


  }

  void prepareService() async{
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
  _hasProfileImage() async{

    Reference storageReference =
    _firebaseStorage.ref('user_image/${widget.participantName}' + '[1]');
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
    return GestureDetector(
        onTap: () {
          if(widget.senderName!=widget.participantName){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text("Profile"),
                  content: Text("Test"),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: ()async{
                      DatabaseService(uid:_user.uid).updateRequest(widget.participantName,widget.senderName);
                      if(await Vibration.hasVibrator() && !await Vibration.hasAmplitudeControl()){
                        (Theme.of(context).platform == TargetPlatform.android)? Vibration.vibrate(

                            duration: 3000,
                            pattern: [100,50,200,30,1000,2000]
                        ): Vibration.vibrate();
                      }else{
                          print("${Theme.of(context).platform}: vibration Null");
                          }
                    },
                        child:Text("친구 요청"))
                  ]
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
                              DatabaseService(userName: widget.participantName).hasFriendRequest(widget.senderName).then((value){
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