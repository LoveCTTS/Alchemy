import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//로딩할때 뜨는 위젯
class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: SpinKitRing(
          color: Colors.white,
          size: 50.0,
        )
      ),
    );
  }
}