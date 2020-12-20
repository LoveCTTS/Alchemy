import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MikeMessageTile extends StatelessWidget {

  final String senderName;
  final String mikeMessage;

  MikeMessageTile({this.senderName,this.mikeMessage});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 200, height: 70.0,
            padding: EdgeInsets.all(0.5), //Gradient Border size 조절
            child: GestureDetector(
              onTap: () async {

              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("$senderName : $mikeMessage", style:TextStyle(fontWeight: FontWeight.bold,fontSize:15,color: Colors.white,
                            fontFamily: "RobotoMono-italic"))),
                ),
              ),

            ),
          )]
    );
  }
}
