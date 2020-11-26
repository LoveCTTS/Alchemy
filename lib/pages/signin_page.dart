import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../helper/helper_functions.dart';
import 'home_page.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../shared/constants.dart';
import '../shared/loading.dart';

class SignInPage extends StatefulWidget {
  final Function toggleView; //함수형 변수 toggleView생성
  SignInPage({this.toggleView}); // 인스턴스생성 시 새로운 함수를 받아서 인스턴스에 저장

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _auth = AuthService(); //인증서비스 이용을위해 AuthService 인스턴스 생성
  final _formKey = GlobalKey<FormState>(); //현재 앱 전체에서 사용될수있는 독특한 키를 생성하기 위해 GlobalKey인스턴스 생성
  bool _isLoading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';


  _onSignIn() async {
    if (_formKey.currentState.validate()) { // GlobalKey가 올바르게 생성되었다면
      setState(() {
        _isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(email, password).then((result) async { //이메일과 비밀번호를 입력받아서 인증하고, 결과를 result에 반환
        if (result != null) { //result에 값이 반환되었다면
          QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(email); //매개변수 email에 저장된 email과 동일한 사용자의 데이터정보 저장

          await HelperFunctions.saveUserLoggedInSharedPreference(true); //사용자가 잘 로그인되었기때문에 true로 변경
          await HelperFunctions.saveUserEmailSharedPreference(email); //현재 사용자의 email을 저장
          await HelperFunctions.saveUserNameSharedPreference(
            userInfoSnapshot.documents[0].data['fullName']
          );// 현재 사용자의 풀네임을 저장

          // 로그인이 잘된상태이기때문에 그것에 대한 출력을 하는 부분
          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          //로그인후 첫 페이지 어디로 할지 선정(현재 HomePage()로 설정 됨)
          //context에는 현재 클래스에서 가장 가까운 인스턴스의 상태를 저장하고있다.(이해하기어렵다면, 그냥 로그인 할때 사용자 정보를 context에 저장하고있다고보면된다.)
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        }
        //로그인 인증이 실패한경우
        else {
          setState(() {
            error = 'Error signing in!';
            _isLoading = false;
          });
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading ? Loading() : Scaffold( //로그인 성공시 Loading() / 실패시 Scaffold 실행(참고로 첫 로그인페이지화면과는 똑같이생겼지만, 여기 화면은 별개다.
      body: Form(
        key: _formKey, //GlobalKey로 만든 _formKey로 한 위젯을 또다른 위젯으로 대체할때??바꿀때?(replacement) 제어 용도로 사용
        child: Container(
          color: Color(0xffe6e6fa),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0), //horizontal이 커질수록 양옆으로 폭 조절, vertical은 위아래로 폭 조절
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text("Alchemy", style: TextStyle(color: Colors.black, fontSize: 100, fontFamily: 'Satisfy'))),//앱 메인 제목(FittedBox를 통해 기기에 따라 유연하게 적용)
                
                  SizedBox(height: 30.0), //위젯사이 높낮이 조절을위해 SizeBox 사용
                
                  Text("로그인", style: TextStyle(color: Colors.black, fontSize: 18.0)),

                  SizedBox(height: 20.0),
                
                  TextFormField( //입력칸 위젯
                    style: TextStyle(color: Colors.black),
                    decoration: textInputDecoration.copyWith(labelText: '이메일'), //입력칸 라벨

                    // email 입력시 규칙 적용
                    validator: (val) {
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please enter a valid email";
                    },

                    //사용자가 입력칸에 값이 변경(삽입/삭제/다른값으로 변경)
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    }, //
                  ),
                
                  SizedBox(height: 15.0),

                  //비밀번호 입력칸
                  TextFormField(
                    style: TextStyle(color: Colors.black),
                    decoration: textInputDecoration.copyWith(labelText: '비밀번호'), //라벨
                    validator: (val) => val.length < 6 ? '비밀번호는 최소 6자리 이상' : null, // 비밀번호 규칙
                    obscureText: true,

                    //비밀번호 입력칸에 비밀번호가 변경(삽입/삭제/다른값으로 변경)
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                
                  SizedBox(height: 20.0),

                  //Sign in 버튼 디자인
                  SizedBox(
                    width: double.infinity, //RaisedButton에 Size조절이없어서 SizedBox로 너비조절
                    height: 50.0, // 높이 조절
                    child: RaisedButton(
                      elevation: 0.0, // 바꿔봐도 바뀌는게없음..(안중요)(z-coordinate at which to place this button relative to its parent 라고하는데 이해안됨.)
                      color: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      child: Text('로그인', style: TextStyle(color: Colors.white, fontSize: 16.0)),

                      //버튼을 누르면 직접 만든 _onSignIn()함수 실행
                      onPressed: () {
                        _onSignIn();
                      }
                    ),
                  ),
                
                  SizedBox(height: 10.0),
                  
                  Text.rich( //Text의 생성자 Text.rich

                    TextSpan(
                      text: "계정이 아직 없으신가요? ",
                      style: TextStyle(color: Colors.black, fontSize: 12.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: '계정 생성',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline
                          ),

                          //아래 명령어에서 ..는 TapGestureRecognizer이라는 클래스의 인스턴스를 생성(TapGestureRecognizer() 이라고하면 바로 생성됨.(new TapGestureRecognizer()과 같은 의미))
                          //함과 동시에 바로 그 인스턴스안에있는 onTap 속성 or 필드를 사용하겠다는의미
                          //쉽게 말해서 아래 명령어는 register here 글을 누르면 register_page로 이동한다.(widget.toggleView()는 고정된 기능의 함수가 아니고,
                          //signin_page에 들어오는 함수가 항상 바뀔수있도록 작성해놨기때문에 항상 다른 함수로 바뀔수있다.
                          //참고로 onTap에는 () {widget.toggleView;}형태의 이름없는 함수의 주소가 저장이 됨. ()는 매개변수가 표기되는곳인데, 여기서는 매개변수 사용안함

                         recognizer: TapGestureRecognizer()..onTap = () {
                            widget.toggleView();
                          },
                        ),
                      ],
                    ),
                  ),
                
                  SizedBox(height: 10.0),
                
                  Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0)),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
