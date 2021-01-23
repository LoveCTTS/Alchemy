import 'package:flutter/material.dart';

class ImageAtTouch extends StatefulWidget {
  final String image;
  ImageAtTouch(this.image);
  @override
  ImageAtTouchState createState() => ImageAtTouchState();
}

class ImageAtTouchState extends State<ImageAtTouch> {

  bool isTouchedScreen=false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(

        body:Stack(children:[
          GestureDetector(
            onTap: (){
              setState(() {
                isTouchedScreen==false?isTouchedScreen=true: isTouchedScreen=false;

              });
            },
              child:Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(image:NetworkImage(widget.image))
            ),
          )),
          isTouchedScreen?SizedBox.shrink() :Container(
            alignment: Alignment.centerLeft,
              width:screenSize.width,height: 70,color: Color(0xcc212121),
              child: IconButton(

                onPressed: (){
                  Navigator.of(context).pop();
                },
                  icon: Icon(Icons.arrow_back,color: Colors.white,)
          )),]));
  }
}

