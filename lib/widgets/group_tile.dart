import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class GroupTile extends StatelessWidget {
  //그룹 타일도 한번 실행후 상태 변화가 없기때문에 StatelessWidget 사용
  final String userName;
  final String groupId;
  final String groupName;
  bool _isNotJoined = true;
  FirebaseUser _user;

  GroupTile({this.userName, this.groupId, this.groupName});

  final kInnerDecoration = BoxDecoration(
    color: Color(0xfffffafa),
    border: Border.all(color: Colors.white),
    borderRadius: BorderRadius.circular(32),
  );

  final kGradientBoxDecoration = BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xff000080),Color(0xff4b0082)]),
    border: Border.all(
      color: Colors.white,
    ),
    borderRadius: BorderRadius.circular(32),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
          width: 350, height: 50.0, decoration: kGradientBoxDecoration,
          padding: EdgeInsets.all(0.5), //Gradient Border size 조절
            child: GestureDetector(
            onTap: () async {
              _user = await FirebaseAuth.instance.currentUser();
              await DatabaseService(uid: _user.uid,userName:userName).JoiningGroupAtTouch(
                  groupId, groupName, userName);
              //채팅방으로 가기
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  ChatPage(groupId: groupId,
                    userName: userName,
                    groupName: groupName,)));
            },
              child: Padding(
              padding: const EdgeInsets.all(3.0),
                child: Container(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(groupName, style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Color(0xff483d8b),
                      fontFamily: "RobotoMono-italic"))),
                    decoration: kInnerDecoration
                ),
              ),

          ),
        ),SizedBox(height:10)]
    );
  }
}
