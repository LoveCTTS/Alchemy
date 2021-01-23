/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkproto/pages/email_verify2.dart';
import 'package:linkproto/services/auth_service.dart';

class EmailVerifyPage extends StatefulWidget {
  @override
  EmailVerifyPageState createState() => EmailVerifyPageState();
}

class EmailVerifyPageState extends State<EmailVerifyPage> {

  String email='';
  String password='';
  AuthService authService = AuthService();
  FToast fToast;


  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }
  _showToast(String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Color(0xdd48d1cc),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(message),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //backgroundColor: Color(0xff212121),
      resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.all(30),
            child:Column(

          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                  icon: Icon(Icons.arrow_back)),
              Text("가입하기",style: TextStyle(color: Colors.black,fontSize: 30)),
              SizedBox(height:50),
              TextField(
              onChanged: (val) {
                email= val;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                labelText: "이메일을 입력하세요.",
              ),
              style: TextStyle(
                  color: Colors.black
              )

          ),SizedBox(height:20),
              TextField(
                  onChanged: (val) {
                    password=val;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: "암호를 입력하세요.",
                  ),
                  style: TextStyle(
                      color: Colors.black
                  )

              ),SizedBox(height:50),
              GestureDetector(
                onTap: ()async{

                  FocusScope.of(context).unfocus();
                  await authService.registerWithEmailAndPassword_2(email, password).then((message){
                    _showToast(message);
                  });
                  await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      EmailVerifyPage2()));
                },
                  child:Container(
                      alignment: Alignment.center,
                      width:MediaQuery.of(context).size.width,
                      height:50,
                      color: Colors.blue,
                      child: Text("다음")
              ))

        ]))
    );
  }
}

*/
