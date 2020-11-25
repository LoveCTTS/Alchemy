import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/widgets/friend_tile.dart';
import 'package:linkproto/widgets/mikemessage_tile.dart';
import '../services/database_service.dart';
import '../widgets/message_tile.dart';
import '../widgets/friendrequest_tile.dart';

class FriendsChatPage extends StatefulWidget {


  //data
  final String groupId;
  final String userName;
  final String groupName;


  FriendsChatPage({
    this.groupId,
    this.userName,
    this.groupName
  });
  //Optional named parameter 개념이 사용되어진 생성자이기때문에 ChatPage 인스턴스 생성시 반드시 argument: value와 같은 형식대로해야하고,
  // 위 3가지 parameter을 전부다 넣어줘야만 컴파일이 된다.
  // 자세한 사항은 오른쪽 링크 참조  https://www.growingwiththeweb.com/2013/05/optional-parameters-in-dart.html

  @override
  _FriendsChatPageState createState() => _FriendsChatPageState();
}

class _FriendsChatPageState extends State<FriendsChatPage> {

  FirebaseUser _user;
  String uid;
  String _userName='';
  Stream<QuerySnapshot> _chats; //QuerySnapshot 데이터가 여러개인 Stream형태 _chat변수
  TextEditingController messageEditingController = new TextEditingController();
  //TextEditingController형의 인스턴스를 저장하는 변수 messageEditingController 생성

  _getUserInfo() async {

    _user = await FirebaseAuth.instance.currentUser(); //현재 접속된 사용자에 대한 정보를 _user에 저장
    //SharedPreference에 저장된 username을 매개변수 value에 복사하고 현재 아고라페이지의 _userName에 초기화
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });

  }
  @override
  void initState() {
    super.initState();
    _getUserInfo();

    //DB로 부터 groupID를 통해 특정 그룹의 채팅정보를 반환받아서 val 매개변수에저장한후 Stream<QuerySnapshot>형태의 _chat변수에 저장함으로써,
    // 여태까지 그룹채팅방에 쓰여진 모든 채팅을 볼 수있음.
    //참고로 QuerySnapshot은 firebase에서 만들어진 클래스이고, Query의 결과가 저장되어있음.
    DatabaseService().getChats(widget.groupId).then((val) {
      // print(val);
      setState(() {
        _chats = val;
      });
    });
  }

  Widget _chatMessages(){
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot){
        //특정 그룹(방)의 message collection을 통해 오래된날짜기준으로 정렬된(오름차순 or 내림차순) 특정 방의 모든 채팅메세지가 snapshot에 저장이됨.
        //이해 안된다면 database_service page의 getChats함수를 볼것(이 함수의 반환값이 _chats로 들어왔고, 이 들어온내용이 snapshot 매개변수에 정보가 저장이 되어 사용됨)


        return snapshot.hasData ?  ListView.builder(

            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){

              //메세지 말풍선
              return MessageTile(
                message: snapshot.data.documents[index].data["message"],
                sender: snapshot.data.documents[index].data["sender"],
                sentByMe: widget.userName == snapshot.data.documents[index].data["sender"],
              );
            }
        )
            :
        Container();
      },
    );
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }
  //메세지 전송
  _sendMessage() {
    if (messageEditingController.text.isNotEmpty) { //메세지 입력란에 text가 비어있지않다면

      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text, //메세지 입력란에 입력한 메세지
        "sender": widget.userName, //특정 사용자 이름
        'time': DateTime.now().millisecondsSinceEpoch,//현재시간을 millisecond단위로 time에 저장
      };
      //

      DatabaseService().sendMessage(widget.groupId, chatMessageMap); //특정 groupId에 위 Map<String,dynamic>형태의 데이터 전송

      //메세지 전송후 messageEditingController을 다음 메세지를 입력할수잇도록 ""로 비워줌
      setState(() {
        messageEditingController.text = "";

      });
    }
  }

  void _popupFriendRequest(BuildContext context) {


    Widget closeButton = FlatButton(
        minWidth: 80,
        child: Text("Close"),
        onPressed:  () async {
          Navigator.of(context).pop();
        });


    AlertDialog alert = AlertDialog(
        title: Text("친구 요청 목록 "),
        content: Container(
            width: 250,
            height: 300,
            child:ListView(children: [
                StreamBuilder(
                stream: DatabaseService(uid:_user.uid,userName: _userName).userCollection.document(_userName).snapshots(),
            builder: (context, snapshot) {
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
              if(!snapshot.hasData) { return Text("Currently Not Friend",style: TextStyle(fontSize:30));
              } else {
                var friendRequestList=snapshot.data["request"];
                return ListView.builder( //ListView.builder 생성자를 사용한 이유는 그룹이 정말 많이생성되어도 모두 다 리스팅될수도있도록 하기위함이다.(어몽어스처럼)
                    itemCount: friendRequestList.length, //일단 확성기에 4개만 보이도록 하였음.(입력칸 없어지는 문제때문에)
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      int reqIndex=friendRequestList.length-index-1;
                      return FriendRequestTile(
                        receiverName: _userName,
                        senderName: friendRequestList[reqIndex].toString(),
                      );

                    }
                );
              }
            }),

            ]
            )) ,

        actions: <Widget>[
          closeButton

        ]
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  //채팅 페이지 디자인 관련 코드인데, 직접 실시간으로 조절하면서 디자인하면되니 설명은 생략함.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("메신저", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        elevation: 0.0,


        actions: <Widget> [
          SizedBox(
            height: 20.0,
            width: 35.0,
            child: IconButton(
              icon: Icon(Icons.favorite,color: Colors.pinkAccent),
              padding: EdgeInsets.all(0.0),
              iconSize: 30,
              onPressed: () {},
            )
        ),

          SizedBox(
              height: 20.0,
              width: 35.0,
              child: IconButton(
                icon: Icon(Icons.person_add,color: Colors.purpleAccent),
                padding: EdgeInsets.all(0.0),
                iconSize: 30,
                onPressed: () {

                  _popupFriendRequest(context);

                },
              )
          ),
        ]

      ),
      drawer: Container(
          width:150,
          child:Drawer(
            child: StreamBuilder(


                stream: DatabaseService(uid: uid,userName:_userName).userCollection.document(_userName).snapshots(),
                builder: (context, snapshot) {

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
                if(!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {

                  var friendList=snapshot.data["friends"];
                  return ListView.builder( //ListView.builder 생성자를 사용한 이유는 그룹이 정말 많이생성되어도 모두 다 리스팅될수도있도록 하기위함이다.(어몽어스처럼)
                      itemCount: friendList.length, //일단 확성기에 4개만 보이도록 하였음.(입력칸 없어지는 문제때문에)
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        int reqIndex=friendList.length-index-1;
                        return FriendTile(

                          friendName: friendList[reqIndex],
                        );

                      }
                  );
                }
                }
                ),

    )),



      body: Container(
        child: Stack(
          children: <Widget>[
            _chatMessages(),
            // Container(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.grey[700],
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageEditingController,
                        style: TextStyle(
                            color: Colors.white
                        ),
                        decoration: InputDecoration(
                            hintText: "Send a message ...",
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 16,
                            ),
                            border: InputBorder.none
                        ),
                      ),
                    ),

                    SizedBox(width: 12.0),

                    GestureDetector(
                      onTap: () {
                        _sendMessage();
                      },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Center(child: Icon(Icons.send, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
