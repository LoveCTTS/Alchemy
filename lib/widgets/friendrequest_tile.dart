import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/agora_page.dart';


class FriendRequestTile extends StatelessWidget { //그룹 타일도 한번 실행후 상태 변화가 없기때문에 StatelessWidget 사용

  final String senderName;

  FriendRequestTile({this.senderName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text("Profile"),
                  content: Text("Test"),
                  actions: <Widget>[

                    FlatButton(
                        onPressed: ()async{

                        },
                        child:Text("친구 요청"))
                  ]
              );
            },
          );
        },
        child:SizedBox( //Card size 조절하기위한 SizedBox
            height:65.0,
            child: Card( //ListTile을 조금 더 쉽게 나은 디자인을하기 위한 Card
                child: ListTile(
                    title: Text(senderName,style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold))
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