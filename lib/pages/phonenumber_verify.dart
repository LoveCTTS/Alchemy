import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/pages/create_nick_name_phone.dart';
import 'package:linkproto/pages/phonenumber_verify2.dart';
import 'package:linkproto/services/auth_service.dart';

class PhoneNumberVerifyPage extends StatefulWidget {
  @override
  PhoneNumberVerifyPageState createState() => PhoneNumberVerifyPageState();
}

class PhoneNumberVerifyPageState extends State<PhoneNumberVerifyPage> {

  String phoneNumber='';
  String message='';
  TextEditingController phoneNumberController= TextEditingController();

  AuthService _auth = AuthService();


  @override
  void initState() {
    phoneNumberController.addListener(() { });

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
              Icon(Icons.phone,size: 100), Text("내 전화번호:",style:TextStyle(color: Colors.white, fontSize: 30))
            ],),
            TextField(
              controller: phoneNumberController,
                maxLength: 10,
                keyboardType: TextInputType.number,

                decoration: InputDecoration(

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white, width :1.0),
                  ),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width:2)),
                  labelText: "맨 앞자리 번호 제외 후 입력해주세요.",
                  labelStyle: TextStyle(color: Colors.white),
                  prefix: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text("+1",style: TextStyle(color: Colors.white),)
                  )
                ),
                style: TextStyle(
                    color: Colors.white
                )
            ),
            SizedBox(height:50),
            GestureDetector(
              onTap: () async{

                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    PhoneNumberVerify2Page(phoneNumberController.text)));

              },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  width:MediaQuery.of(context).size.width,
                    child:Text("다음",style: TextStyle(color: Colors.white,fontSize: 30))
            ))
          ],)
        )
    );
  }
}

