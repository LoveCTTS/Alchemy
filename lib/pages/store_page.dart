import 'package:flutter/material.dart';
import 'package:linkproto/services/admob.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {


  int whichSelected=0;
  String itemName='';
  String itemImagePath='';
  String itemDescription='';
  int itemPrice=0;
  int purchaseItemCount=1;
  int purchasedMoney=20000;

  @override
  void initState() {


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          title:Text("상점",style: TextStyle(color: Colors.white)),

        actions: [
          Padding(
            padding: EdgeInsets.all(10),
              child:
          GestureDetector(
            onTap: (){},
              child:
              Container(
                width:screenSize.width/3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(20)
                    ),
                    color: Colors.black
                  ),

                  child: Row(children: [

                    SizedBox(width:5),
                    Container(
                  width:30,
                  height:30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10)
                    ),
                    image: DecorationImage(
                      image: AssetImage("images/diamond.png"),
                    ),
                  ),
                ),SizedBox(width:10),
                    Text(purchasedMoney.toString()),
                    SizedBox(width:screenSize.width/35),
                    Icon(Icons.add),

          ]))
          ))
        ],
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: Color(0xff212121),
          child:Column(
            children: [

              Container(
                  width: screenSize.width,
                  height:screenSize.height/5,
                  color: Colors.orange,
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child:
                  Row(

                    children: [
                      Padding(
                          padding: EdgeInsets.only(left:10),
                          child:Container(
                        width:80,
                        height:80,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(
                              Radius.circular(10)
                          ),

                          image: DecorationImage(
                            image: whichSelected==0?AssetImage("images/main_image.png"): AssetImage(itemImagePath)

                          ),
                        ),
                      )),
                      Container(

                          child:Column(
                          children: [
                            whichSelected==0?SizedBox(height:20): Text(itemName,style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height:5),
                            Container(
                              width: 150,
                                height:50,
                                child: whichSelected==0?Text("아이템을 선택해주세요.", style: TextStyle(fontSize:15,fontWeight: FontWeight.bold)):Text(itemDescription)
                            ),
                            Container(
                              height:20,
                                width:100,

                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)
                                  ),
                                ),
                                child:Row(

                                    children:[
                                      SizedBox(width:5),

                                      Container(
                                  width:30,
                                  height:30,
                                  decoration: BoxDecoration(

                                    image: DecorationImage(
                                      image: AssetImage("images/diamond.png"),
                                    ),
                                  ),
                                ),SizedBox(width:10),
                                      whichSelected==0?
                                      Text("0",style: TextStyle(color: Colors.white)):
                                      Text((itemPrice* purchaseItemCount).toString(),style: TextStyle(color: Colors.white,fontSize: 10))
                              ]
                            ))

                      ])),
                      Container(
                        padding: EdgeInsets.only(top:15),
                          child:Column(children:[

                            Row(children:[

                              GestureDetector(
                              onTap: (){

                                setState(() {
                                  if(purchaseItemCount>0) {
                                    purchaseItemCount -= 1;
                                  }
                                });
                              },
                              child:Container(
                                  width:30,
                                  height:30,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black

                                  ),
                                  child:Icon(Icons.remove,color: Colors.white,))),
                          SizedBox(width:20),
                          Container(
                            child:Text(purchaseItemCount.toString())
                          ),
                          SizedBox(width:20),
                          GestureDetector(
                            onTap: (){

                              setState(() {
                                purchaseItemCount+=1;
                              });
                            },
                              child:Container(
                            width:30,
                              height:30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black

                              ),
                              child:Icon(Icons.add,color:Colors.white)))
                        ]),
                            SizedBox(height:30),

                            GestureDetector(
                              onTap: (){

                                setState(() {
                                  if(purchasedMoney >= purchaseItemCount * itemPrice) {
                                    purchasedMoney -= purchaseItemCount * itemPrice;
                                  }else if(!(purchasedMoney >= purchaseItemCount * itemPrice)){
                                    print("Can't buy");
                                  }
                                });


                              },
                                child: Container(

                                width:100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                    ),
                                  color: Colors.black,
                                ),


                                    child: Center(child:Text("구매하기",style: TextStyle(color:Colors.white,fontSize: 20)))
                        )
                            )
                      ]))

                    ],)
              ),

              Container(
                width: screenSize.width,
                height: screenSize.height/1.8,
                  child:CustomScrollView(
                    primary: false,
                    slivers: <Widget>[
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                        sliver: SliverGrid.count(
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 40,
                          crossAxisCount: 3,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  whichSelected=1;
                                  itemName="평범한 확성기";
                                  itemImagePath="images/normal_megaphone.png";
                                  itemDescription="전 서버의 유저들에게 한마디할 수 있는 아이템";
                                  itemPrice=5000;
                                });
                              }, child:Wrap(children: [
                                    Container(
                                  width:screenSize.width/5,
                                  height:screenSize.height/5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10)
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage("images/normal_megaphone.png"),
                                    ),
                                  ),
                                      child: Align(alignment: Alignment.bottomCenter,child:Text("평범한 확성기",style: TextStyle(color:Colors.white)))
                                ),

                              ],),
                            ),

                            GestureDetector(
                                onTap: (){

                                  setState(() {
                                    whichSelected=2;
                                    itemName="황금 확성기";
                                    itemImagePath="images/gold_megaphone.png";
                                    itemDescription="꽤 긴 시간동안 전서버의 유저들에게 한마디할 수 있는 아이템";
                                    itemPrice=6000;
                                  });
                                },
                                      child: Wrap(children: [
                                        Container(
                                          width:screenSize.width/5,
                                          height:screenSize.height/5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage("images/gold_megaphone.png"),
                                            ),
                                          ),
                                          child: Align(alignment: Alignment.bottomCenter,child:Text("황금 확성기",style: TextStyle(color:Colors.white)))

                                        ),

                                      ],),
                                ),
                            GestureDetector(
                                onTap: (){

                                  setState(() {
                                    whichSelected=3;
                                    itemName="손편지";
                                    itemImagePath="images/envelop.png";
                                    itemDescription="친구 아닌 유저에게 한마디할 수 있는 아이템";
                                    itemPrice=7000;
                                  });
                                },
                                      child: Wrap(children: [
                                        Container(
                                          width:screenSize.width/5,
                                          height:screenSize.height/5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage("images/envelop.png"),
                                            ),
                                          ),
                                          child: Align(alignment: Alignment.bottomCenter,child:Text("손편지",style: TextStyle(color:Colors.white)))
                                        ),
                                      ],),
                                ),
                            GestureDetector(
                                onTap: (){

                                  setState(() {
                                    whichSelected=4;
                                    itemName="사랑의 묘약";
                                    itemImagePath="images/love_potion.png";
                                    itemDescription="사귀고싶은 사람에게 고백하기";
                                    itemPrice=8000;
                                  });
                                },
                                      child: Wrap(children: [
                                        Container(

                                          width:screenSize.width/5,
                                          height:screenSize.height/5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage("images/love_potion.png"),
                                            ),
                                          ),
                                            child:Align(alignment: Alignment.bottomCenter,child:Text("사랑의 묘약",style: TextStyle(color:Colors.white)))
                                        ),
                                      ],)),
                            GestureDetector(
                                onTap: (){

                                  setState(() {
                                    whichSelected=5;
                                    itemName="광고제거피스톨";
                                    itemImagePath="images/ad_block.png";
                                    itemDescription="하단 배너 광고 제거";
                                    itemPrice=999999;
                                  });
                                },
                              child: Wrap(children: [
                                        Container(

                                          width:screenSize.width/5,
                                          height:screenSize.height/5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage("images/ad_block.png"),
                                            ),
                                          ),
                                          child: Align(alignment: Alignment.bottomCenter,child:Text("광고제거",style: TextStyle(color:Colors.white)))


                                        ),

                                      ],),
                                ),
                            GestureDetector(
                                onTap: (){

                                  setState(() {
                                    whichSelected=6;
                                    itemName="신비로운 물약";
                                    itemImagePath="images/mysterious_nickname_color.png";
                                    itemDescription="닉네임의 색깔을 무작위로 바꿔주는 염색약";
                                    itemPrice=5000;
                                  });
                                }, child: Wrap(children: [
                                        Container(
                                          width:screenSize.width/5,
                                          height:screenSize.height/5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage("images/mysterious_nickname_color.png"),
                                            ),
                                          ),
                                          child: Align(alignment: Alignment.bottomCenter,child:Text("신비로운 물약",style: TextStyle(color:Colors.white)))
                                        ),

                                      ],),
                                ),


                          ],
                        ),
                      ),
                    ],
                  )

              )
          ],
      ))

    );
  }
}

