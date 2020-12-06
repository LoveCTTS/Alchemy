import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class GroupTile extends StatefulWidget {
  //그룹 타일도 한번 실행후 상태 변화가 없기때문에 StatelessWidget 사용
  final String userName;
  final String groupId;
  final String groupName;


  @override
  GroupTileState createState() => GroupTileState();

  GroupTile({this.userName, this.groupId, this.groupName});
}
class GroupTileState extends State<GroupTile>{

  User _user;
  bool isSecretRoom = false;
  String roomPassword = '';
  bool isSameRoomPassword = false;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL;
  bool _hasNetworkImage=false;
  String _userName='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prepareService();

  }

  void _prepareService() async{
    _user= FirebaseAuth.instance.currentUser;
    _hasNetworkImage = await groupNetworkImage();
    _userName = await HelperFunctions.getUserNameSharedPreference();

  }

  groupNetworkImage() async{

    Reference storageReference =
    _firebaseStorage.ref().child("users/${_user.uid}");
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
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,   //수정완료 - 아고라페이지 방 버튼 왼쪽 정렬
        children: <Widget>[
          GestureDetector(
        onTap: () async {
          _user = FirebaseAuth.instance.currentUser;
          isSecretRoom = await DatabaseService().isSecretRoom(widget.groupId);
          if(isSecretRoom){
            showDialog(
          context: context,
          builder: (BuildContext context) {
            return Padding(
                padding: EdgeInsets.only(top:250,bottom:250),
                child:AlertDialog(
                    title: Text("암호") ,
                    content:Column(
                        children:[
                          SizedBox(height:50),
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

                                  isSameRoomPassword = await DatabaseService().isSameRoomPassword(widget.groupId, roomPassword);
                                  if(isSameRoomPassword){
                                    await DatabaseService(uid: _user.uid).JoiningGroupAtTouch(
                                        widget.groupId, widget.groupName, widget.userName);
                                    //채팅방으로 가기
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                        ChatPage(groupId: widget.groupId,
                                          userName: widget.userName,
                                          groupName: widget.groupName,)));
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
        await DatabaseService(uid: _user.uid,userName:widget.userName).JoiningGroupAtTouch(
            widget.groupId, widget.groupName, widget.userName);
        //채팅방으로 가기
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChatPage(groupId: widget.groupId,
              userName: widget.userName,
              groupName: widget.groupName,)));
      }

    },
            child:Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: 70.0,
                    child: Row(
                        children: [
                      Container(
                        width:50,
                        height:50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: _hasNetworkImage? NetworkImage(_profileImageURL):AssetImage("images/default.png"),
                          ),
                        ),
                      ),
                      Text(widget.groupName, style:TextStyle(fontWeight: FontWeight.bold,fontSize:15,color:Colors.black/*Color(0xff483d8b)*/,
                          fontFamily: "RobotoMono-italic")),
                          SizedBox(width:10),
                          StreamBuilder(
                            stream: DatabaseService().groupCollection.document(widget.groupId).snapshots(),
                            builder: (context,snapshot){

                              List<Widget> children;
                              if(snapshot.hasError){

                                children = <Widget>[
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text('Error: ${snapshot.error}'),
                                  )
                                ];
                              }
                              if(!snapshot.hasData){

                                return CircularProgressIndicator();
                              }else{

                                String memberCount = snapshot.data["members"].length.toString();
                                return Text(memberCount);
                              }

                            }
                          )



                      ])
                              //decoration: kInnerDecoration

    ),

          ),
        ]);
  }
}
