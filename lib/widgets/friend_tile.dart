import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/pages/friends_chat_page.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendTile extends StatefulWidget {

  final String groupId;
  final String friendName;

  FriendTile({this.groupId, this.friendName});

  @override
  _FriendTileState createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile>{

  FirebaseUser _user;
  String _userName='';

  @override
  void initState() {

    super.initState();
    getUserInfo();
  }
  getUserInfo() async{
    _userName=await HelperFunctions.getUserNameSharedPreference();
    _user = await FirebaseAuth.instance.currentUser();
  }
  void _popupTest(BuildContext context) {

    Widget sendButton = FlatButton(
        minWidth: 80,
        child: Text("채팅하기"),
        onPressed:  () async {

          Navigator.of(context).pop();
          //채팅방으로 가기
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              FriendsChatPage(groupId: widget.groupId,
                userName: _userName)));
        });
    Widget closeButton = FlatButton(
        minWidth: 80,
        child: Text("닫기"),
        onPressed:  () async {
          Navigator.of(context).pop();
        });

    AlertDialog test = AlertDialog(
        title: Text("Test"),
        content: Text("Test"),
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
          GestureDetector(
            onTap: (){
              _popupTest(context);

            },
              child:Container(
                width: MediaQuery.of(context).size.width,
                height:50, color: Colors.grey,
                padding: EdgeInsets.all(0.5),
                child: Align(
                  alignment: Alignment.centerLeft,
                    child:Text("${widget.friendName}", style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Colors.white,
                    fontFamily: "RobotoMono-italic"))
                )//Gradient Border size 조절
          )),
          SizedBox(height:10)]
    );
  }
}
