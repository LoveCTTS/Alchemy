import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MikeMessageTile extends StatelessWidget {

  final String senderName;
  final String mikeMessage;
  FirebaseUser _user;

  MikeMessageTile({this.senderName,this.mikeMessage});

  final kInnerDecoration = BoxDecoration(
    color: Colors.white, //수정
    border: Border.all(color: Colors.white),
    borderRadius: BorderRadius.circular(32),
  );

  final kGradientBoxDecoration = BoxDecoration(
    gradient: LinearGradient(colors: [Colors.white,Colors.white]), //수정
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
            width: 200, height: 50.0, decoration: kGradientBoxDecoration,
            padding: EdgeInsets.all(0.5), //Gradient Border size 조절
            child: GestureDetector(
              onTap: () async {

              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text("$senderName : $mikeMessage", style:TextStyle(fontWeight: FontWeight.bold,fontSize:10,color: Color(0xff483d8b),
                            fontFamily: "RobotoMono-italic"))),
                    decoration: kInnerDecoration
                ),
              ),

            ),
          ),SizedBox(height:10)]
    );
  }
}
