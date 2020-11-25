import 'package:flutter/material.dart';
import '../pages/register_page.dart';
import '../pages/signin_page.dart';

class AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {

  bool _showSignIn = true;
  
  void _toggleView() {
    setState(() {
      _showSignIn = !_showSignIn;
    });
  } //함수를 선언하였지만, 실행이 된건 아니다.

  @override
  Widget build(BuildContext context) {
    if(_showSignIn) {
      return SignInPage(toggleView: _toggleView); //_toggleView 함수를 여기서 실행하는게아니고 SignInPage인스턴스를 생성하고 여기 안에서 실행
    }
    else {
      return RegisterPage(toggleView: _toggleView); //_toggleView함수를 여기서 실행하는게아니고, RegisterPage인스턴스 생성하고 여기 안에서 실행
    }
  }
}
