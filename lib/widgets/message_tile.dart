import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatelessWidget { //MessageTile은 고정되어있기때문에 StatelessWidget사용

  //message내용과 전송한사람과 전송자에의해 보내졌는지 진위여부를 알아내는 중간에 값이 변경되면 안되기때문에 final을 통해 상수화 시킴
  final String message;
  final String sender;
  final bool sentByMe;
  final String time;


  MessageTile({this.message, this.sender, this.sentByMe,this.time});
  //외부에서 MessageTile를 생성할때 3개의 값을 넣어서 생성하면, 인스턴스를 생성함과동시에 넣은 값이 인스턴스에 초기화 되어짐.


  //채팅 말풍선 디자인 코드
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: sentByMe ? 0 : 24,
          right: sentByMe ? 24 : 0
          ),
        alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: sentByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
          borderRadius: sentByMe ? BorderRadius.only(
            topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
            bottomLeft: Radius.circular(23)
          )
          :
          BorderRadius.only(
            topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
            bottomRight: Radius.circular(23)
          ),
          color: sentByMe ? Colors.purple : Colors.grey[700],
        ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(sender.toUpperCase(), textAlign: TextAlign.start, style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5)),
              SizedBox(height: 7.0),
              Text(message, textAlign: TextAlign.start, style: TextStyle(fontSize: 15.0, color: Colors.white)),
              Text(time, textAlign: TextAlign.start, style: TextStyle(fontSize: 10.0, color: Colors.black))

          ],
        ),
      ),
    );
  }
}