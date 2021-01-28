import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/pages/check_position_phoneuser_page1.dart';
import 'package:linkproto/services/database_service.dart';
import 'home_page.dart';

class CreateNickNamePhonePage extends StatefulWidget {

  final User result;
  final isJoined;

  CreateNickNamePhonePage(this.result, this.isJoined);

  @override
  CreateNickNamePhonePageState createState() => CreateNickNamePhonePageState();
}

class CreateNickNamePhonePageState extends State<CreateNickNamePhonePage> {

  TextEditingController nickNameController= TextEditingController();

  @override
  void initState() {
    nickNameController.addListener(() { });
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //앱바 색을 Scaffold와 일치시켜도 다르게 나타나기때문에 투명화 시킨 후 elevation을 0.0으로 주면 투명화 되면서 동시에 appBar기능 사용가능
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        backgroundColor: Color(0xff212121),
        body: Container(
            child:Column(children: [
              Row(
                children: [
                  Icon(Icons.phone,size: 100), Text("내 닉네임:",style:TextStyle(color: Colors.white, fontSize: 30))
                ],),
              TextField(
                  controller: nickNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: "닉네임을 입력해주세요.",
                  ),
                  style: TextStyle(
                      color: Colors.black
                  )
              ),SizedBox(height:50),
              GestureDetector(
                  onTap: () async{

                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                              CheckPositionPhoneUser1(isJoined : widget.isJoined, nickName:nickNameController.text,result:widget.result)));


                      },
                  child: Container(
                      alignment: Alignment.center,
                      color: Colors.blue,
                      width:MediaQuery.of(context).size.width,
                      child:Text("시작하기",style: TextStyle(color: Colors.white,fontSize: 30))
                  ))
            ],)
        )
    );
  }
}

