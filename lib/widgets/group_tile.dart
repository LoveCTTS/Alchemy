import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class GroupTile extends StatefulWidget {
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
  void initState(){
    // TODO: implement initState
    super.initState();
     _prepareService();

  }

   _prepareService() async{
    _user= FirebaseAuth.instance.currentUser;
    _userName = await HelperFunctions.getUserNameSharedPreference();
    _hasNetworkImage = await groupNetworkImage();


  }

  groupNetworkImage() async{

    Reference storageReference =
    _firebaseStorage.ref('group_image/$_userName' + '[0]');
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
          isSecretRoom = await DatabaseService().isSecretRoom(widget.groupId);
          if(isSecretRoom){
            showDialog(
          context: context,
          builder: (BuildContext context) {
                return AlertDialog(
                    title: Row(children: [
                      Icon(Icons.https_rounded, size: 40, color: Colors.white),
                      SizedBox(width:150),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 40,
                      ),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                      )
                    ]) ,

                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xff9932cc)),
                        borderRadius: BorderRadius.all(
                            Radius.circular(20.0)
                        )
                    ),
                    content:Column(
                      mainAxisSize: MainAxisSize.min,
                        children:[
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
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(),
                                      labelText: "방 비밀번호를 입력해주세요."
                                  )
                              )),
                          IconButton(

                              icon: Icon(Icons.meeting_room_rounded, size: 40, color: Colors.white),
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
                                }
                                  // 여기안에서는 스낵바 기능이 안되는걸로 추측됨. Get.snackbar('Hi','i am modren');

                              }
                          )
                        ]),

                );

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
            child:Padding(
              padding: EdgeInsets.only(left:10),
                child:Container(
                    color: Color(0xff212121),
                    width: MediaQuery.of(context).size.width,
                    height: 70.0,
                    child: Row(
                        children: [
                      Container(
                        width:50,
                        height:50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color(0xff9932cc),
                              width: 1,
                              ),
                          image: DecorationImage(
                            image: _hasNetworkImage? NetworkImage(_profileImageURL):AssetImage("images/main_image.png"),
                          ),
                        ),
                      ),
                      SizedBox(width:10),
                      Text(widget.groupName, style:TextStyle(fontWeight: FontWeight.bold,fontSize:15,color:Colors.white/*Color(0xff483d8b)*/,
                          fontFamily: "RobotoMono-italic")),
                          SizedBox(width:5),
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
                                return Text(memberCount, style: TextStyle(color: Colors.white));
                              }

                            }
                          )



                      ])
                              //decoration: kInnerDecoration

    )),

          ),
        ]);
  }
}
