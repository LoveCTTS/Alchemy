import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:linkproto/pages/groupChatSettings.dart';
import 'package:linkproto/services/admob.dart';
import 'package:linkproto/widgets/participant_tile.dart';
import '../services/database_service.dart';
import '../widgets/message_tile.dart';
import 'package:firebase_storage/firebase_storage.dart';


class GroupChatPage extends StatefulWidget {

  //data
  final String groupId;
  final String userName;
  final String groupName;


  GroupChatPage({
    this.groupId,
    this.userName,
    this.groupName
  });
  //Optional named parameter 개념이 사용되어진 생성자이기때문에 GroupChatPage 인스턴스 생성시 반드시 argument: value와 같은 형식대로해야하고,
  // 위 3가지 parameter을 전부다 넣어줘야만 컴파일이 된다.
  // 자세한 사항은 오른쪽 링크 참조  https://www.growingwiththeweb.com/2013/05/optional-parameters-in-dart.html

  @override
  GroupChatPageState createState() => GroupChatPageState();
}

class GroupChatPageState extends State<GroupChatPage> {
  
  Stream<QuerySnapshot> _chats; //QuerySnapshot 데이터가 여러개인 Stream형태 _chat변수
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController _scrollController; // 스크롤을 컨트롤하기위한 변수선언
  int _currentScrollPosition=0; //현재 스크롤 위치에 따른 선택을 편리하게하기위한 변수선언
  FocusNode myFocusNode;
  bool hasFocus=false;
  User _user;
  AdMobManager adMob= AdMobManager();
  final _picker = ImagePicker();
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  File _image;
  File _video;
  bool isSwitchedPlus=false;
  String _profileImageURL = '';
  String _profileVideoURL = '';
  int imageUploadCount=0;
  int videoUploadCount=0;
  //FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Message> _messages;






  @override
  void initState() {
    super.initState();
    prepareService();

  }
  @override
  void dispose(){

    prepareService().dispose();
    super.dispose();
  }
  prepareService() async{

    _user = FirebaseAuth.instance.currentUser;
    _scrollController= ScrollController(); //스크롤 컨트롤하기위한 인스턴스생성
    _scrollController.addListener(_scrollListener); //스크롤을 실시간으로 Listen하기위해 Listener 추가
    myFocusNode = FocusNode();
    myFocusNode.addListener(() {

      setState(() {
        hasFocus = myFocusNode.hasFocus;
      });
      print("Has Focus: $hasFocus");
    });
    _messages = List<Message>();


    //DB로 부터 groupID를 통해 특정 그룹의 채팅정보를 반환받아서 val 매개변수에저장한후 Stream<QuerySnapshot>형태의 _chat변수에 저장함으로써,
    // 여태까지 그룹채팅방에 쓰여진 모든 채팅을 볼 수있음.
    //참고로 QuerySnapshot은 firebase에서 만들어진 클래스이고, Query의 결과가 저장되어있음.
    DatabaseService().getChats(widget.groupId).then((val) {
      // print(val);
      setState(() {
        _chats = val;
      });
    });
    DatabaseService().getImageUploadCount(widget.userName).then((_imageUploadCount){
      setState(() {
        imageUploadCount = _imageUploadCount;
      });
    });
    DatabaseService().getVideoUploadCount(widget.userName).then((_videoUploadCount){
      setState(() {
        videoUploadCount = _videoUploadCount;
      });
    });

    //말그대로 Local Notification 이고, 다른 사용자에게 Notification을 적용하는기능은 아님. 나중에 쓸수도있어서 주석처리해놓음.
    /*var androidInitialize = AndroidInitializationSettings('app_icon');
    var iOSinitialize = IOSInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSinitialize);*/

    /*_flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onSelectNotification: notificationSelected);*/
    _getToken();
    _configureFirebaseListeners();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true,alert: true)
    );


  }


  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> _message) async{
          print("onMessage: $_message");
          _setMessage(_message);
        },
        onLaunch: (Map<String, dynamic> _message) async {
          print("onLaunch: $_message");

          _setMessage(_message);
        },
        onResume: (Map<String, dynamic> _message) async{
          print("onResume: $_message");
          _setMessage(_message);
        }
    );
  }
  _setMessage(Map<String,dynamic> message){
    final notification = message['notification'];
    print(notification);
    final data = message['data'];
    print(data);
    final String title = notification['title'];
    print(title);
    final String body = notification['body'];
    print(body);
    final String mMessage = data['message'];
    print(mMessage);

    setState(() {

      Message m = Message(title,body,mMessage);
      _messages.add(m);
    });
  }
  _getToken(){
    _firebaseMessaging.getToken().then((deviceToken){

      print("deviceToken: $deviceToken");
      DatabaseService().setDeviceToken(deviceToken, widget.groupId);
    });
  }
  Future notificationSelected(String payload) async{
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Notification Payload"),
        content: Text("Payload: $payload")
      )
      );
  }

  //LocalNotification에 필요한 함수
  /*Future<void> _showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }*/


  Widget _chatMessages(){
    return Container(
        height: isSwitchedPlus?MediaQuery.of(context).size.height-300:MediaQuery.of(context).size.height-150,
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
            var dateString = format.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data()["time"]));


            return MessageTile(
              message: snapshot.data.documents[index].data()["message"],
              sender: snapshot.data.documents[index].data()["sender"],
              sentByMe: widget.userName == snapshot.data.documents[index].data()["sender"],
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

  Future<bool> whenPushedMachineBack() {
    Navigator.of(context).pop();
    return adMob.showBanner();

  }




  void _uploadImageToStorage(ImageSource source) async {

    PickedFile pickedFile = await _picker.getImage(source: source);
    File image = File(pickedFile.path);
    if (image == null) return;

    setState(() {
      _image = image;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의. 사용자의 uid를 이용하여 파일명의 중복 가능성 제거
    Reference storageReference = _firebaseStorage.ref('group_chat_image/${widget.groupName}/${widget.userName}/${widget.userName}_$imageUploadCount');

    try{
      await storageReference.putFile(_image).then((_) async{
        //위 함수가 실패해도 아래 명령어가 동작할까? 실패하면 아래 명령어로 가지않고 바로 FirebaseException으로 가서 Failed Upload가 실행될까? 확실히 모르겠으나,
        //putFile의 코드를보면 예외발생시 바로 아래 예외코드로 가기때문에 콜백은 동작안할것으로 보이기때문에, 예외쪽에서 DB에 등록된 ImageUploadCount를 -1해주지않아도 될것으로보임.

        await DatabaseService().updateImageUploadCount(widget.userName);
        await DatabaseService().getImageUploadCount(widget.userName).then((_imageUploadCount){
          setState(() {
            imageUploadCount = _imageUploadCount;
          });
        });
      });

    }on FirebaseException catch (e){

      print("Failed Upload");
    }




    String downloadURL = await storageReference.getDownloadURL();



    if(downloadURL!=null){

      setState(() {
        _profileImageURL = downloadURL;

      });

    }
    Map<String, dynamic> chatMessageMap = {
      "message": _profileImageURL, //메세지 입력란에 입력한 메세지
      "sender": widget.userName, //특정 사용자 이름
      'time': DateTime.now().millisecondsSinceEpoch,//현재시간을 millisecond단위로 time에 저장
    };
    //

    DatabaseService().sendMessage(widget.groupId, chatMessageMap); //특정 groupId에 위 Map<String,dynamic>형태의 데이터 전송


  }

   _uploadVideoToStorage(ImageSource source) async {

    PickedFile pickedFile = await _picker.getVideo(source: source);
    File video = File(pickedFile.path);
    if (video == null) return;

    setState(() {
      _video = video;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의. 사용자의 uid를 이용하여 파일명의 중복 가능성 제거
    Reference storageReference = _firebaseStorage.ref('group_chat_video/${widget.groupName}/${widget.userName}/${widget.userName}_$videoUploadCount');

    try{
      await storageReference.putFile(_video).then((_) async{
        await DatabaseService().updateVideoUploadCount(widget.userName);
        await DatabaseService().getVideoUploadCount(widget.userName).then((_videoUploadCount){
          setState(() {
            videoUploadCount = _videoUploadCount;
          });
        });

      });

    }on FirebaseException catch (e){
      print("Failed Upload");

    }




    String downloadURL = await storageReference.getDownloadURL();



    if(downloadURL!=null){

      setState(() {
        _profileVideoURL = downloadURL;

      });

    }

    Map<String, dynamic> chatMessageMap = {
      "message": _profileVideoURL, //메세지 입력란에 입력한 메세지
      "sender": widget.userName, //특정 사용자 이름
      'time': DateTime.now().millisecondsSinceEpoch,//현재시간을 millisecond단위로 time에 저장
    };
    //

    DatabaseService().sendMessage(widget.groupId, chatMessageMap);
    // 업로드된 사진의 URL을 페이지에 반영


  }




  //채팅 페이지 디자인 관련 코드인데, 직접 실시간으로 조절하면서 디자인하면되니 설명은 생략함.
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    //그룹채팅창에서 아무데나 터치해도 될수있게 하기위해 GestureDetector로 Scaffold 전체를 감싸줌
    return WillPopScope(
      onWillPop: whenPushedMachineBack,
        child:GestureDetector(
      onTap:(){
        setState(() {
          isSwitchedPlus=false;
        });
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
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,),onPressed: (){
          adMob.showBanner();
          Navigator.of(context).pop();
        },),
        backgroundColor: Color(0xff9932cc),
        elevation: 0.0,
      ),


      backgroundColor: Color(0xff212121),
      endDrawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Color(0xff212121),
          ),
          child:Container(
          width:250,
            child: Stack(
            children: <Widget>[
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
                alignment: Alignment.bottomCenter,
                child:
                Container(
                  color: Colors.black54,
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      IconButton(

                          icon: Icon(Icons.exit_to_app_rounded,size:40, color: Colors.white),

                          onPressed: () async{


                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            await DatabaseService(uid:_user.uid).deleteMembers(widget.groupId, widget.groupName, widget.userName); //그룹에서 맴버 삭제
                            await DatabaseService().deleteGroupIfNoMembers(widget.groupId);// 맴버가 아무도없다면 그룹 폭파

                          }
                      ),
                      IconButton(
                          icon: Icon(Icons.settings),
                          iconSize: 30,
                          color: Colors.white,
                          onPressed: () async{

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GroupChatSettingsPage()));
                          }
                      )
                    ])),
              ),

            ]
    )
      )
      ),
        body:SingleChildScrollView(child:
          Column(
          children: <Widget>[
            _chatMessages(), //채팅 메세지 보여주는 위젯
            Container(
              width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Color(0xffb23aee),
                child: Row(
                  children: <Widget>[
                    isSwitchedPlus?IconButton(
                        onPressed: () async{

                          //FocusScope.of(context).requestFocus(myFocusNode);
                          // FocusScope.of(context).unfocus();
                          setState(() {
                            isSwitchedPlus=false;
                          });

                        },
                        icon: Icon(Icons.close_rounded,size: 40, color: Colors.white)) :
                    IconButton(
                        onPressed: () async{

                          FocusScope.of(context).unfocus();
                          setState(() {

                            isSwitchedPlus=true;
                          });

                          },
                        icon: Icon(Icons.add_box_outlined,size: 40, color: Colors.white)
                    ),
                    SizedBox(width:10),
                    Expanded(
                      child: TextField(
                        focusNode: myFocusNode,
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
                        height: 35.0,
                        width: 35.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(child: Icon(Icons.send, color: Color(0xff4f2f4f))),
                      ),
                    )
                  ],
                ),
              ),
            isSwitchedPlus?Container(
                color: Colors.grey,
                width: deviceWidth,
                height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height:100,
                      color:Colors.blue,
                      child:
                IconButton(

                    icon: Icon(Icons.photo_rounded,size: 50, color: Colors.white),

                  onPressed: () {
                     _uploadImageToStorage(ImageSource.gallery);

                  },
                )),
                    /*Container(
                        width:100,
                        height:100,
                        color:Colors.blue,
                        child:
                        IconButton(
                            onPressed: () {
                              _showNotification();

                            },
                            icon: Icon(Icons.check,size: 50, color: Colors.white))
                    ),*/
                Container(
                  width:100,
                    height:100,
                    color:Colors.blue,
                    child:
                IconButton(
                    onPressed: () {
                      _uploadVideoToStorage(ImageSource.gallery);

                    },
                  icon: Icon(Icons.video_call_rounded,size: 50, color: Colors.white))
                )]

              )
            )
                :SizedBox.shrink(),
          ],
        )),
      floatingActionButton: _currentScrollPosition==0?Stack(children:[ //버튼 위치 구체적지정을위해 Stack에 넣어줘야 함
        Positioned( //버튼 위치 구체적 지정
            bottom: 60,
            right:0,
            left:300,
          child: Container(
            height:50,
              width:50,
              child:FloatingActionButton(//가장 위쪽에 위치하면 가장아래로가는 버튼 생성

            onPressed: () {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent+200.0);
              },
            child: Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 30.0),
            backgroundColor: Color(0xff9932cc),
            elevation: 0.0,
      ))
      )
      ])
          :null,
    )
    ));
  }
}
class Message {
  String title;
  String body;
  String message;

  Message(title, body, message) {
    this.title = title;
    this.body = body;
    this.message = message;
  }
}
