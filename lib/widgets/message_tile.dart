import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatefulWidget {
  //MessageTile은 고정되어있기때문에 StatelessWidget사용

  //message내용과 전송한사람과 전송자에의해 보내졌는지 진위여부를 알아내는 중간에 값이 변경되면 안되기때문에 final을 통해 상수화 시킴
  final String message;
  final String sender;
  final bool sentByMe;
  final String time;

  @override
  MessageTileState createState() => MessageTileState();

  MessageTile({this.message, this.sender, this.sentByMe, this.time});
//외부에서 MessageTile를 생성할때 3개의 값을 넣어서 생성하면, 인스턴스를 생성함과동시에 넣은 값이 인스턴스에 초기화 되어짐.

}
class MessageTileState extends State<MessageTile>{


  bool hasProfileImage=false;
  FirebaseStorage _firebaseStorage=FirebaseStorage.instance;
  String _profileImageURL='';


  void initState(){
    super.initState();
    prepareService();
  }

  void prepareService() async{

    setState(() async{

      hasProfileImage= await _hasProfileImage();
    });

  }

  Future<bool> _hasProfileImage() async{

    Reference storageReference =
    _firebaseStorage.ref('user_image/${widget.sender}' + '[1]');
    String downloadURL = await storageReference.getDownloadURL();
    if(downloadURL == null){
      return false;
    }else if(downloadURL != null){
      setState((){
        _profileImageURL = downloadURL;
      });
      return true;
    }
    return false;
  }
  //채팅 말풍선 디자인 코드
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 12,
          right:widget.sentByMe ? 12 : 0
          ),
        alignment:widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Wrap(
            spacing: 5,
              children: [
            widget.sentByMe?SizedBox.shrink():
            Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: hasProfileImage? NetworkImage(_profileImageURL):AssetImage("images/main_image.png")
                      ),
                    )
                ),

            Column(
                crossAxisAlignment:widget.sentByMe? CrossAxisAlignment.end:CrossAxisAlignment.start,
                children: [
                  Text(widget.sender,style:TextStyle(color: Colors.white)),SizedBox(height:5),
                  Container(
                    margin:widget.sentByMe ? EdgeInsets.only(left: 10) : EdgeInsets.only(right: 10),
                    padding: EdgeInsets.only(top: 2, bottom: 5, left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius:widget.sentByMe ? BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)
                      )
                          :
                      BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)
                      ),
                      color:widget.sentByMe ? Colors.purple[200] : Colors.grey[400],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 7.0),
                        Text(widget.message, textAlign: TextAlign.start, style: TextStyle(fontSize: 15.0, color: Colors.black)),
                      ],
                    ),
                  ),
                  Text(widget.time, textAlign: TextAlign.start, style: TextStyle(fontSize: 10.0, color: Colors.white))
                ]),
          ])
    );


  }
}
