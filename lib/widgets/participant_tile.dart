import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/chat_page.dart';
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

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    prepareService();


  }

  void prepareService() {
    _user = FirebaseAuth.instance.currentUser;
    DatabaseService().isChief(widget.participantName, widget.groupId).then((value){
      setState(() {
        isChief=value;
      });

    });
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
        child:SizedBox( //Card size 조절하기위한 SizedBox
            height:65.0,
            child: Card( //ListTile을 조금 더 쉽게 나은 디자인을하기 위한 Card
                child: ListTile(
                    title: Text(widget.participantName,style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold))
                ),
                color:  isChief ?Colors.blue:Colors.purple,
                margin: EdgeInsets.symmetric(vertical:10.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10)
                )

            )
        )

    );




  }
}