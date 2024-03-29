import 'dart:async';
import 'dart:io';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/admob.dart';
import 'package:linkproto/services/database_service.dart';
import '../helper/helper_functions.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/group_tile.dart';
import '../widgets/mikemessage_tile.dart';
import 'package:firebase_admob/firebase_admob.dart';

class AgoraPage extends StatefulWidget {
  @override
  _AgoraPageState createState() => _AgoraPageState();
}

class _AgoraPageState extends State<AgoraPage> {
  User _user;
  String _groupName;
  String _userName = '';
  String _groups='';
  String _email='';
  int changeSkin=0;
  String mikeMessageInMikePopup;
  String roomPassword;
  StateSetter _setState;
  bool enablePassword=false;
  bool enableRoomImage=false;
  bool hasMembers=false;
  Future<List<QueryDocumentSnapshot>> getGroupSnapshots ;
  AdMobManager adMob = AdMobManager();
  FocusNode _myFocusNode;



  // initState
  @override
  void initState() {

    adMob.showBanner();
    super.initState();
    prepareService();

  }

  @override
  void dispose(){

    super.dispose();

  }

  prepareService() async {
    _user = FirebaseAuth.instance.currentUser; //현재 접속된 사용자에 대한 정보를 _user에 저장

    getGroupSnapshots= DatabaseService().getGroupSnapshots();
    //SharedPreference에 저장된 username을 매개변수 value에 복사하고 현재 아고라페이지의 _userName에 초기화
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    _myFocusNode = FocusNode();

  }

  Widget mike(){
    return Padding(
      padding: EdgeInsets.only(left:10),
        child:Container(
        width: MediaQuery.of(context).size.width, //아고라페이지에서 보이는 확성기 칸이 어떤 기기에서도 너비가 자동으로 맞춰짐.
        height: 30,
        color: Color(0xff212121),
        child: GestureDetector( //컨테이너를 버튼처럼 누를수있도록 GestureDetector을 사용함.
            onTap: (){
              _popupMike(context);
            },
            child: StreamBuilder( //실시간으로 확성기 데이터가 가장 최근 것으로 실시간으로 보여줄수있도록 StreamBuilder을 사용하였음.
                stream: DatabaseService().mikeMessageCollection.orderBy('createdTime',descending: true).snapshots(),
                //데이터가 실시간으로 바뀌는데, 생성된 시간을 기준으로하여 정렬
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
                  if(!snapshot.hasData){ return CircularProgressIndicator();}
                  else {
                    List mikeMessageList = snapshot.data.documents
                        .map((e) {
                      return e.data;
                    }).toList();
                    //snapshot에 저장된 데이터에 접근하기위해서는 위와같이 List형태로 바꿔서 접근하는게 표준적임.
                    return Row(children: <Widget>[

                      Bubble(

                        color: Color(0xff9932cc),
                          child: Text(mikeMessageList[0]()["sender"], style: TextStyle(color: Colors.white))),

                      Bubble(
                        nip: BubbleNip.leftTop,
                          child:Text(mikeMessageList[0]()["mikeMessage"],style: TextStyle(color: Colors.black))),

                    ]);
                  }
                }
            )
        )
    ));
  }
//DB내의 모든 방 리스팅하기
  Widget allGroupsList() {

    return FutureBuilder(
    future: getGroupSnapshots,
        builder: ( _ , AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot){
      if(snapshot.hasData){
      List allGroups = snapshot.data.map((e) {return e.data;}).toList();
        return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
        itemCount: allGroups.length,
        shrinkWrap: true, // 스크롤 뷰의 범위를 보고있는 내용에따라 결정해야하는지 여부(별로 중요하지않음)
        itemBuilder: (context,index){
          int reqIndex=allGroups.length-index-1;
          return GroupTile(
              userName: _userName, //특정 유저의 풀네임을 userName에 저장
              groupId: allGroups[reqIndex]()["groupId"].toString(),
              groupName: allGroups[reqIndex]()["groupName"].toString()
          );
        }
        );
      }else{
        return CircularProgressIndicator();
      }}
    );

  }

  //마이 버튼 눌렀을때 뜨는 창 ( 마피아 확성기 버튼 눌렀을때 뜨는 창과 같은 것)
  void _popupMike(BuildContext context) {

    Widget sendButton = IconButton(
      icon: Icon(
        Icons.arrow_circle_up_rounded,
        color: Colors.white,
        size: 40,
      ),
      onPressed:  () async {

        await DatabaseService(uid: _user.uid).addMikeMessage(_userName, mikeMessageInMikePopup);
          }
          );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(width: 180),
                IconButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size:30
                  ),
                )
              ]),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Color(0xff9932cc)),
              borderRadius: BorderRadius.all(
                  Radius.circular(20.0)
              )
          ),
          content: Container(
              width: 250,
              height: 250,
              child:ListView(children: [
                Container(
                    height:200,
                    decoration: BoxDecoration(

                        border: Border.all(color: Colors.white, width:2),
                        borderRadius: BorderRadius.all(
                            Radius.circular(20.0)
                        )
                    ),
                    child:StreamBuilder(
                        stream: DatabaseService(uid:_user.uid,userName: _userName).mikeMessageCollection.orderBy('createdTime').snapshots(),
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
                          if(!snapshot.hasData) { return Text("Currently Not Mike",style: TextStyle(fontSize:30));
                          } else {
                            List mikeMessageList = snapshot.data.docs.map((e){return e.data;}).toList();
                            return ListView.builder( //ListView.builder 생성자를 사용한 이유는 그룹이 정말 많이생성되어도 모두 다 리스팅될수도있도록 하기위함이다.(어몽어스처럼)
                                itemCount: mikeMessageList.length, //일단 확성기에 4개만 보이도록 하였음.(입력칸 없어지는 문제때문에)
                                shrinkWrap: true,
                                itemBuilder: (context,index){
                                  int reqIndex=mikeMessageList.length-index-1;
                                  return MikeMessageTile(
                                    senderName: mikeMessageList[reqIndex]()["sender"].toString(),
                                    mikeMessage: mikeMessageList[reqIndex]()["mikeMessage"].toString(),
                                  );

                                }
                            );
                          }
                        })),

                SizedBox(height:5),
                Row(children: [
                  Container(
                      width:220,
                      height:40,
                      child: TextField(
                          focusNode: _myFocusNode,
                          onChanged: (val) {
                            if (val.length<45) {
                              mikeMessageInMikePopup = val;
                            }
                          },
                          decoration: InputDecoration(

                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: "45자 내외로",
                          ),
                          style: TextStyle(
                              color: Colors.black

                          )

                      )
                  ),
                  SizedBox(width:10),
                  sendButton



                ])

              ]
              )) ,

        );
      },
    );
  }

  void _popupMakeRoom(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
                title: Text("Create a group",style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xff9932cc)),
                    borderRadius: BorderRadius.all(
                        Radius.circular(20.0)
                    )
                ),
                backgroundColor: Colors.black,
                content: StatefulBuilder(
                    builder: (context,setState){
                      _setState = setState;
                      return Column(
                        mainAxisSize: MainAxisSize.min, //Alertdialog 요소에 맞게 길이 조절해주는 특성
                          children:[
                            SizedBox(
                              height:30,
                                child:TextField(
                              cursorHeight: 40,
                                onChanged: (val) {
                                  _groupName = val;
                                },
                                style: TextStyle(
                                    fontSize: 10.0,
                                    height: 2.0,
                                    color: Colors.black
                                ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                labelText: "RoomName"
                              )
                            )),
                            SizedBox(height:30),
                            Row(
                                children:[
                                  SizedBox(
                                      width:80,
                                      child:Text("password",style: TextStyle(color: Colors.white))),
                                  SizedBox(
                                      width: 100,
                                      height: 25,
                                      child: Switch(
                                          activeColor: Color(0xff9932cc),
                                          value: enablePassword,
                                          onChanged: (value) {
                                            _setState(() {
                                              enablePassword = value;
                                              print(enablePassword);
                                            }
                                            );
                                          }
                                      )
                                  ),

                                ]
                            ),
                            SizedBox(height:20),
                            SizedBox(
                                width:250,height:30,
                                child:TextField(
                                    enabled: enablePassword==false?false:true, //스위치 false이면 비밀번호 입력못하고, true면 비밀번호 입력가능
                                    onChanged: (val) {
                                      roomPassword = val;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(),
                                      labelText: "Password",
                                    ),
                                    style: TextStyle(
                                        fontSize: 10.0,
                                        height: 2.0,
                                        color: Colors.black
                                    )
                                )),
                            SizedBox(height:20),

                          ]);
                    }
                ),
              actions: [

                FlatButton(

                  child: Text("Cancel",style:TextStyle(fontSize:20,color:Colors.red)),
                  onPressed:  () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(

                    child: Text("Create",style:TextStyle(fontSize:20,color:Colors.blue)),
                    onPressed:  () async {
                      if(_groupName != null && roomPassword==null) {
                        await HelperFunctions.getUserNameSharedPreference().then((val) {
                          DatabaseService(uid: _user.uid).createGroup(val, _groupName);
                          Navigator.of(context).pop();
                        });

                      }else if(_groupName != null && roomPassword!=null){
                        await HelperFunctions.getUserNameSharedPreference().then((val){
                          DatabaseService(uid:_user.uid).createSecretGroup(val,_groupName,roomPassword);
                          Navigator.of(context).pop();
                        });
                      }}
                )
              ],
            );

      },
    );


  }

  // Agora Page 메인 위젯 디자인 코드
  @override
  Widget build(BuildContext context) {

    return Platform.isIOS? SizedBox.shrink():Scaffold(
          //앱 상단바의 위아래 높낮이 조절을위해 PreferredSize 를 사용하여야하고, 이를 상단바에만 적용하기위해서 SafeZone(그냥 직접 만든 것)을 사용
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
                child: SafeArea(
                    child: AppBar(
                        title: Text("Agora", style: TextStyle(color: Colors.white, fontSize: 30,fontFamily : "Satisfy" )),
                        backgroundColor: Color(0xff9932cc),
                        //IconButton사이 간격을 조절하기위해서는 Icon을 포함하고있는 Container을 조절해야하는데, 그것을 조절하는방법이 SizedBox밖에 없음.
                        actions: <Widget>[
                          //새로고침 버튼
                          SizedBox(
                              height: 20.0,
                              width: 35.0,
                              child: IconButton(
                                icon: Icon(Icons.autorenew,color: Colors.white),
                                padding: EdgeInsets.all(0.0),
                                iconSize: 30,
                                onPressed: () {
                                  setState(() {
                                    getGroupSnapshots= DatabaseService().getGroupSnapshots();
                                  });
                                },
                              )
                          ),


                          /*
                          //파란색 원 버튼
                          SizedBox(
                          height: 21.0,
                          width: 25.0,

                              child: IconButton(

                                icon: Icon(Icons.fiber_manual_record,color: Colors.blue),

                                padding: EdgeInsets.all(0.0),

                                onPressed: () {
                                  setState(() {
                                    changeSkin=1;
                                  });
                                  },
                            )
                          ),

                          //빨간색 원 버튼
                          SizedBox(
                              height: 21.0,
                              width: 25.0,
                              child: IconButton(
                                icon: Icon(Icons.fiber_manual_record,color: Colors.red),
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  setState(() {
                                    changeSkin=2;
                                  });
                                },
                              )
                          ),

                          //초록색 원 버튼
                          SizedBox(
                              height: 21.0,
                              width: 25.0,
                              child: IconButton(
                                icon: Icon(Icons.fiber_manual_record,color: Colors.green),
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  setState(() {
                                    changeSkin=3;
                                  });
                                },
                              )
                          ),  */

                          //방만들기버튼

                          GestureDetector(
                            onTap: () async{

                              _popupMakeRoom(context);
                            },
                                child:IconButton(

                                  icon: Icon(Icons.add,color: Colors.white),

                                  iconSize: 30,)



                        )
                        ]
                    )
                )
            ),
        resizeToAvoidBottomInset: false,
        body:
        Column(
            children:<Widget>[
              SizedBox(height:20),
              mike(), //확성기를 ListView가 아닌 Column안에 넣음으로써 그룹채팅 방들을 스크롤해도 같이 위로 안올라가게 막을수있다.
          Expanded( //위젯에 expaned 위젯을 추가하면 레이아웃에서 overflow가 안보이게 할수있다.
              child:SingleChildScrollView(
                  child: allGroupsList())),
        ]
        ),
        /*Container(

            height: MediaQuery.of(context).size.height,
            child: AllgroupsList(),
          */
          /*
          decoration: BoxDecoration( //배경색 gradient 적
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,


                stops: [
                0.1,
                0.4,
                0.6,
                0.9
                ],
                colors: [
                Colors.yellow,
                Colors.red,
                Colors.indigo,
                Colors.teal
                ])), //Scaffold 클래스의 body 속성에는 하나의 클래스만 사용하는 것이 원칙이고 기본이다.
            */

      backgroundColor: Color(0xff212121)


        );
  }
}
