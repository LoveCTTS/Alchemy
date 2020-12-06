import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkproto/pages/agora_page.dart';
import 'package:linkproto/widgets/participant_tile.dart';
import '../services/database_service.dart';
import '../widgets/message_tile.dart';
import '../routes/routes.dart';


class ChatPage extends StatefulWidget {

  //data
  final String groupId;
  final String userName;
  final String groupName;



  ChatPage({
    this.groupId,
    this.userName,
    this.groupName
  });
  //Optional named parameter 개념이 사용되어진 생성자이기때문에 ChatPage 인스턴스 생성시 반드시 argument: value와 같은 형식대로해야하고,
  // 위 3가지 parameter을 전부다 넣어줘야만 컴파일이 된다.
  // 자세한 사항은 오른쪽 링크 참조  https://www.growingwiththeweb.com/2013/05/optional-parameters-in-dart.html

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  
  Stream<QuerySnapshot> _chats; //QuerySnapshot 데이터가 여러개인 Stream형태 _chat변수
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController _scrollController; // 스크롤을 컨트롤하기위한 변수선언
  int _currentScrollPosition=0; //현재 스크롤 위치에 따른 선택을 편리하게하기위한 변수선언
  User _user;

  @override
  void initState() {
    super.initState();
    getUserID();
    _scrollController= ScrollController(); //스크롤 컨트롤하기위한 인스턴스생성
    _scrollController.addListener(_scrollListener); //스크롤을 실시간으로 Listen하기위해 Listener 추가


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
  getUserID() async{
    _user = FirebaseAuth.instance.currentUser;

  }

  Widget _chatMessages(){
    return Container(

        height: MediaQuery.of(context).size.height-150,
        width: MediaQuery.of(context).size.width, //기기별 디스플레이에맞게 너비조절시 MediaQuery사용
        child: StreamBuilder(
      stream: _chats,
      builder: (context, snapshot){

        //특정 그룹(방)의 message collection을 통해 오래된날짜기준으로 정렬된(오름차순 or 내림차순) 특정 방의 모든 채팅메세지가 snapshot에 저장이됨.
        //이해 안된다면 database_service page의 getChats함수를 볼것(이 함수의 반환값이 _chats로 들어왔고, 이 들어온내용이 snapshot 매개변수에 정보가 저장이 되어 사용됨)
        return snapshot.hasData ?  ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: snapshot.data.documents.length,
          controller: _scrollController,
          shrinkWrap: true,
          itemBuilder: (context, index){
            //format에는 화면에 시간을 어떤양식으로 보여줄지를 설정할 수 있음
            var format = new DateFormat.Md().add_jm();
            //DateString은 DateTime.fromMillisecondSinceEpoch함수를 통해 millisecond값을 DateTime형태로 바꿔주고, format함수를통해 보기좋은 시간형태로 바뀐 문자열 형태를 저장
            var dateString = format.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]));


            return MessageTile(
              message: snapshot.data.documents[index].data["message"],
              sender: snapshot.data.documents[index].data["sender"],
              sentByMe: widget.userName == snapshot.data.documents[index].data["sender"],
              time: dateString,
            );
          }
        )
        : Container();
      },
    ));
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
  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
    //"그룹ID_그룹이름" 형태의 문자열에서 indexOf('_')를 이용해 _(언더바)가 있는 인덱스 위치를 알아내고, +1을 하여 subString을 호출하면 그룹이름만 문자열로 반환한다.
  }

  //스크롤의 상태를 파악하기위한 리스너기능
  _scrollListener(){
    if(_scrollController.offset <= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange){ //채팅창에 스크롤을 가장 밑으로 내린상태가 아니라면
      setState(() {
        _currentScrollPosition = 0;
      });
    }
    if(_scrollController.offset >= _scrollController.position.maxScrollExtent
    && !_scrollController.position.outOfRange){ // 채팅창에서 스크롤을 가장 아래로 내렸다면
      setState(() {
        _currentScrollPosition = 1;
      });
    }

  }

  //채팅 페이지 디자인 관련 코드인데, 직접 실시간으로 조절하면서 디자인하면되니 설명은 생략함.
  @override
  Widget build(BuildContext context) {
    //그룹채팅창에서 아무데나 터치해도 될수있게 하기위해 GestureDetector로 Scaffold 전체를 감싸줌
    return GestureDetector(
      onTap:(){
        //사용자들이 그룹채팅창에서 아무데나 터치해도 TextEditor이 내려갈수있게?사라질수있게??하기위해 Focus Out시키는 코드를 삽입
        FocusScopeNode currentFocus = FocusScope.of(context); //현재 앱의 focus를 어디에 두고있는지 정보를 저장하고있는 context를 가져와서 currentFocus에 저장
        //Focus가 현재 잡혀있다면(아래 코드는 포커스관련 오류방지를위해 반드시 작성해주어야함)
        if(!currentFocus.hasPrimaryFocus){
          currentFocus.unfocus();
        }
      },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0.0,
      ),
      endDrawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white12,
          ),
          child:Container(
          width:180,
            child: Stack(
            children: <Widget>[
              Align(child: Text("참여자 목록",style: TextStyle(height:3, fontSize:30))),
              Drawer(
                child: StreamBuilder (
                stream: FirebaseFirestore.instance.collection("groups").doc(widget.groupId).snapshots(),
                builder: (context,snapshot) {
                  List<Widget> children ;
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
                  }
                  else{
                  var result = snapshot.data["members"];
                  return ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (context, index) {
                        int reqIndex=result.length-index-1;
                        return ParticipantTile(
                            senderName : widget.userName,
                            participantName: _destructureName(result[reqIndex].toString()),
                            groupId: widget.groupId,
                        );
                      }
                  );
                  }
                    }
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                  child:IconButton(
                      icon: Icon(Icons.input,size:40, color: Colors.white),
                    onPressed: () async{


                      Navigator.of(context).pop();
                      Navigator.of(context).pop();

                        await DatabaseService(uid:_user.uid).deleteMembers(widget.groupId, widget.groupName, widget.userName); //그룹에서 맴버 삭제
                        await DatabaseService().deleteGroupIfNoMembers(widget.groupId);// 맴버가 아무도없다면 그룹 폭파

                    }
                    ),
                  )
            ]
    )
      )
      ),
        body: SingleChildScrollView(
          child:Column(
          children: <Widget>[
            _chatMessages(), //채팅 메세지 보여주는 위젯
            Container(
              width: MediaQuery.of(context).size.width,
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
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(width: 5.0),

                    GestureDetector(
                      onTap: () {
                        _sendMessage();
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent+200.0); //채팅창 제일 하단으로 이동(스크롤방식)
                        //+200을 해준이유는 채팅입력칸 때문에 maxScrollExtent해도 가장 마지막 채팅만 안보이는 문제때문에 200을 더 해주었음.
                        //참고로 50만 더해줘도 현재 기기에서는 해결되지만, 기기마다 디스플레이가 달라서 +50만으로는 가장 아래 채팅까지 스크롤이 안될수도있기때문에, 넉넉히 200을 더 해주었음.

                        //scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(seconds:1), curve: Curves.fastOutSlowIn)

                      },
                      child: Container(
                        height: 30.0,
                        width: 30.0,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(child: Icon(Icons.send, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              )
          ],
        )),
      floatingActionButton: _currentScrollPosition==0?Stack(children:[ //버튼 위치 구체적지정을위해 Stack에 넣어줘야 함
        Positioned( //버튼 위치 구체적 지정
            bottom: 25,
            right:10,
            left:30,
          child: FloatingActionButton( //가장 위쪽에 위치하면 가장아래로가는 버튼 생
            onPressed: () {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent+200.0);
              },
            child: Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 30.0),
            backgroundColor: Colors.grey[700],
            elevation: 0.0,
      )
      )
      ])
          :null,
    )
    );
  }
}
