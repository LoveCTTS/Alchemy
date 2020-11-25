import 'package:flutter/material.dart';


//로그인 화면에서 입력하는 부분에 대해 디자인할 수 있는 코드
const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.grey) ,//말그대로 label의 디자인을 변경한다.
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.purple, width: 2.0) //입력칸 테두리 디자인
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.deepPurple, width: 5.0) //입력칸이 터치되서 커서가 깜빡일 때 테두리 디자인
  ),
);