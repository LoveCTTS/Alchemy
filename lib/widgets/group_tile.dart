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
  bool isSecretRoom=false;
  String roomPassword='';
  bool isSameRoomPassword=false;



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
  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

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
              isSecretRoom = await DatabaseService().isSecretRoom(groupId);
              if(isSecretRoom){

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                          padding: EdgeInsets.only(top:250,bottom:250),
                          child:AlertDialog(
                              title: Text("비밀 방") ,
                              content:Column(
                                        children:[
                                          SizedBox(height:30),
                                          SizedBox(
                                              height:50,
                                              child:TextField(
                                                  cursorHeight: 30,
                                                  onChanged: (val) {
                                                    roomPassword=val;
                                                  },
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 2.0,
                                                      color: Colors.black
                                                  ),
                                                  decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      labelText: "Input Room Password"
                                                  )
                                              )),

                                          SizedBox(height:50),
                                          Row( children: [
                                            FlatButton(
                                              minWidth: 80,
                                              child: Text("닫기",style:TextStyle(fontSize:20,color:Colors.black)),
                                              onPressed:  () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            SizedBox(width:80),
                                            FlatButton(
                                                minWidth: 80,
                                                child: Text("입장하기",style:TextStyle(fontSize:20,color:Colors.black)),
                                                onPressed:  () async {

                                                  isSameRoomPassword = await DatabaseService().isSameRoomPassword(groupId, roomPassword);
                                                  if(isSameRoomPassword){
                                                    await DatabaseService(uid: _user.uid).JoiningGroupAtTouch(
                                                        groupId, groupName, userName);
                                                    //채팅방으로 가기
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                        ChatPage(groupId: groupId,
                                                          userName: userName,
                                                          groupName: groupName,)));
                                                  }else{
                                                    Navigator.of(context).pop();
                                                    // 여기안에서는 스낵바 기능이 안되는걸로 추측됨. Get.snackbar('Hi','i am modren');
                                                  }

                                                }
                                            )]
                                          )
                                        ])
                          ));

                    },
                  );


              }else{
                await DatabaseService(uid: _user.uid,userName:userName).JoiningGroupAtTouch(
                    groupId, groupName, userName);
                //채팅방으로 가기
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    ChatPage(groupId: groupId,
                      userName: userName,
                      groupName: groupName,)));
              }

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
