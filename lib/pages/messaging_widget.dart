import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class MessagingWidget extends StatefulWidget {
  @override
  MessagingWidgetState createState() => MessagingWidgetState();
}

class MessagingWidgetState extends State<MessagingWidget> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<Message>();
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
  _getToken(){
    _firebaseMessaging.getToken().then((deviceToken){
      print("deviceToken: $deviceToken");
    });
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "hello", style: TextStyle(color:Colors.white)
        ),
      ),
      body: ListView.builder(
        itemCount: null == _messages ? 0 : _messages.length,
        itemBuilder: (context,index){
          return Card(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                _messages[index].message,
                style:TextStyle(
                  fontSize: 16.0,
                  color : Colors.black
                )
              )
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          print("test");
        },
      ),
    );
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

