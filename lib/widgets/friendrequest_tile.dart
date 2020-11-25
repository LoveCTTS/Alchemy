import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/agora_page.dart';


class FriendRequestTile extends StatelessWidget { //그룹 타일도 한번 실행후 상태 변화가 없기때문에 StatelessWidget 사용

  final String receiverName;
  final String senderName;


  FriendRequestTile({this.receiverName,this.senderName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(

                  actions: <Widget>[

                    FlatButton(
                        onPressed: ()async{

                          DatabaseService(userName: receiverName).rejectFriendRequest(senderName);
                          Navigator.of(context).pop();
                        },
                        child:Text("거절")),
                    FlatButton(
                        onPressed: ()async{

                          DatabaseService(userName: receiverName).permitFriendRequest(senderName);
                          Navigator.of(context).pop();
                        },
                        child:Text("수락"))
                  ]
              );
            },
          );
        },
        child:Container( //Card size 조절하기위한 SizedBox
            height:70.0,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(

              border:Border.all(

                color:Colors.black,
                width:4,
              )
            ),
            child: Card( //ListTile을 조금 더 쉽게 나은 디자인을하기 위한 Card
                child: ListTile(
                    title: Center(child:Text(senderName,style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold)))
                ),
                color: Colors.purple,
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