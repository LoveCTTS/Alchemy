import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DatabaseService {

  final String uid; //문자열 형태의 상수형 uid 변수 선언
  final String userName;

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  //인스턴스를 생성함과동시에 uid를 받아오기위한 생성자 선언
  DatabaseService({
    this.uid, this.userName
  });

  // Collection reference클래스를 사용해서 CloudStore에 생성되어있는 users, groups에 접근하기 위해 선언
  final CollectionReference userCollection = FirebaseFirestore.instance.collection(
      'users');
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection(
      'groups');
  final CollectionReference mikeMessageCollection = FirebaseFirestore.instance
      .collection('mikeMessage');
  final CollectionReference friendsChatCollection = FirebaseFirestore.instance
      .collection('friendsChatGroup');


  // 사용자의 데이터를 업데이트
  Future updateUserData(String fullName, String email, String password) async {
    //특정 uid(uid는 DatabaseService가 인스턴스로 생성될때마다 생성자에의해 바뀌어서 저장되기때문에 계속 바뀌며, user마다 반드시 하나의 uid를 가짐) 데이터를 매개변수를 통해 들어온 값으로 변경
    return await userCollection.doc(userName).set({
      'fullName': fullName,
      'email': email,
      'password': password,
      'groups': [],
      'profilePic': '',
      'friends': [],
      'request': [],

    });
  }

  Future updateFriend(String fullName) async {
    //특정 uid(uid는 DatabaseService가 인스턴스로 생성될때마다 생성자에의해 바뀌어서 저장되기때문에 계속 바뀌며, user마다 반드시 하나의 uid를 가짐) 데이터를 매개변수를 통해 들어온 값으로 변경
    return await userCollection.doc(userName).update({
      'friends': FieldValue.arrayUnion([fullName]),

    });
  }

  Future updateRequest(String receiverName, String senderName) async {
    //특정 uid(uid는 DatabaseService가 인스턴스로 생성될때마다 생성자에의해 바뀌어서 저장되기때문에 계속 바뀌며, user마다 반드시 하나의 uid를 가짐) 데이터를 매개변수를 통해 들어온 값으로 변경
    return await userCollection.doc(receiverName).update({
      'request': FieldValue.arrayUnion([senderName]),

    });
  }

  Future addMikeMessage(String senderName, String message) async {
    //특정 uid(uid는 DatabaseService가 인스턴스로 생성될때마다 생성자에의해 바뀌어서 저장되기때문에 계속 바뀌며, user마다 반드시 하나의 uid를 가짐) 데이터를 매개변수를 통해 들어온 값으로 변경
    return await mikeMessageCollection.add({
      'sender': senderName,
      'mikeMessage': message,
      'createdTime': FieldValue.serverTimestamp(),
    });
  }

  // 그룹 생성
  Future createGroup(String userName, String groupName) async {
    //DocumentReferenc형의 groupDocRef변수에 데이터를 json형식으로 묶어서 인자로 보내는 groupCollection.add의 결과값을 저장
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': userName,
      'members': [],
      //'messages': ,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': '',
      'createdTime': FieldValue.serverTimestamp(),

    });
    //FirebaseFirestore 에 groups는 위와 같은 형식으로 데이터 저장 틀이 만들어져있기때문에 반드시 위와같은 json형식을 유지해야만한다.
    //예를 들어서 데이터중간에 'groupdId': '', 대신에 'GroupID' : '', 로 키네임을 바꾼다던가,
    // 'groupdId': []와 같이 value부분의 데이터형이 문자열이아니고, 다른 자료형으로 바꾸면 안된다.

    //groups의 members,groupID 데이터를 업데이트
    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      //uid_username과같은 형식으로 members에 저장됨
      'groupId': groupDocRef.id
      //documentID는 랜덤값으로 생성되며 groupID에 저장됨
    });
    //users의 groups 데이터를 업데이트
    DocumentReference userDocRef = userCollection.doc(userName);
    return await userDocRef.update({
      'groups': FieldValue.arrayUnion(
          [groupDocRef.id + '_' + groupName])
      //documentID_그룹이름 형태로 groups에 저장됨
    });
  }

  Future createSecretGroup(String userName, String groupName,
      String roomPassword) async {
    //DocumentReferenc형의 groupDocRef변수에 데이터를 json형식으로 묶어서 인자로 보내는 groupCollection.add의 결과값을 저장
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': userName,
      'members': [],
      //'messages': ,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': '',
      'createdTime': FieldValue.serverTimestamp(),
      'roomPassword': roomPassword,

    });
    //FirebaseFirestore 에 groups는 위와 같은 형식으로 데이터 저장 틀이 만들어져있기때문에 반드시 위와같은 json형식을 유지해야만한다.
    //예를 들어서 데이터중간에 'groupdId': '', 대신에 'GroupID' : '', 로 키네임을 바꾼다던가,
    // 'groupdId': []와 같이 value부분의 데이터형이 문자열이아니고, 다른 자료형으로 바꾸면 안된다.

    //groups의 members,groupID 데이터를 업데이트
    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      //uid_username과같은 형식으로 members에 저장됨
      'groupId': groupDocRef.id
      //documentID는 랜덤값으로 생성되며 groupID에 저장됨
    });
    //users의 groups 데이터를 업데이트
    DocumentReference userDocRef = userCollection.doc(userName);
    return await userDocRef.update({
      'groups': FieldValue.arrayUnion(
          [groupDocRef.id + '_' + groupName])
      //documentID_그룹이름 형태로 groups에 저장됨
    });
  }

  Future createFriendsChatGroup(String userName, String friendName) async {
    //DocumentReferenc형의 groupDocRef변수에 데이터를 json형식으로 묶어서 인자로 보내는 groupCollection.add의 결과값을 저장
    DocumentReference friendsChatGroupDocRef = await friendsChatCollection.add({
      'members': [],
      //'messages': ,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': '',
      'createdTime': FieldValue.serverTimestamp(),
    });
    await friendsChatGroupDocRef.update({
      'members': FieldValue.arrayUnion([userName]),
      'groupId': friendsChatGroupDocRef.id
    });
    await friendsChatGroupDocRef.update({
      'members': FieldValue.arrayUnion([friendName]),
    });
    return friendsChatGroupDocRef.id;
  }


  rejectFriendRequest(senderName) async {
    await userCollection.doc(userName).update(
        {'request': FieldValue.arrayRemove([senderName])});
  }

  permitFriendRequest(String friendChatGroupId, String senderName) async {
    await userCollection.doc(userName).update(
        {'friends': FieldValue.arrayUnion([friendChatGroupId + '_' + senderName])});
    await userCollection.doc(userName).update(
        {'request': FieldValue.arrayRemove([senderName])});
    await userCollection.doc(senderName).update(
        {'friends': FieldValue.arrayUnion([friendChatGroupId + '_' + userName])});
  }


  // 맴버를 그룹에 추가하거나 삭제하는 코드(검색 후 join버튼 눌렀을때 join하게하고, join버튼 다시누르면 삭제

  Future togglingGroupJoin(String groupId, String groupName,
      String userName) async {
    DocumentReference userDocRef = userCollection.doc(
        userName); //특정 uid로 명칭된 document의 주소를 userDocRef에 저장
    DocumentSnapshot userDocSnapshot = await userDocRef
        .get(); //특정 uid로 명칭된 document내에 저장된 데이터들을 얻어와서 userDocSnapshot에 저장
    DocumentReference groupDocRef = groupCollection.doc(
        groupId); //특정 groupId로 명칭된 doc 주소를 groupDocRef에 저장

    List<dynamic> groups = await userDocSnapshot.data()['groups'];
    //특정 유저의 데이터에서 groups라는 키를 통해 groups에 저장된 모든 값들을 배열 형태로 저장
    //쉽게 말하자면, 사용자가 속한 그룹들의 정보를 groups라는 배열에 저장하는 것이며, groups키 내의 값들은 groupID_방제목 형태로 저장되어있다.

    //그룹에서 맴버 삭제하는 코드
    if (groups.contains(groupId + '_' +
        groupName)) { //togglinGroupJoin함수의 매개변수로 들어온 groupId와 groupName이 특정 유저의 groups데이터에 존재한다면
      await userDocRef.update({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
        //groups에서 매개변수로로 들어온 그룹Id_그룹이름에 해당하는 데이터 삭제
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove([uid + '_' + userName])
        //groups에서 특정 gid로 명칭된 document안의 키값 중 members 내에 저장된 uid_userName 삭제
      });
    }
    //바로 위의 코드와 반대로 그룹에 맴버 추가하는 코드
    else {
      //print('nay');
      await userDocRef.update({
        'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayUnion([uid + '_' + userName])
      });
    }
  }


  Future JoiningGroupAtTouch(String groupId, String groupName,
      String userName) async {
    DocumentReference userDocRef = userCollection.doc(
        userName); //특정 userName으로 명칭된 document의 주소를 userDocRef에 저장
    DocumentSnapshot userDocSnapshot = await userDocRef
        .get(); //특정 uid로 명칭된 document내에 저장된 데이터들을 얻어와서 userDocSnapshot에 저장
    DocumentReference groupDocRef = groupCollection.doc(
        groupId); //특정 groupId로 명칭된 doc 주소를 groupDocRef에 저장

    List<dynamic> groups = await userDocSnapshot.data()['groups'];
    //특정 유저의 데이터에서 groups라는 키를 통해 groups에 저장된 모든 값들을 배열 형태로 저장
    //쉽게 말하자면, 사용자가 속한 그룹들의 정보를 groups라는 배열에 저장하는 것이며, groups키 내의 값들은 groupID_방제목 형태로 저장되어있다.
    await userDocRef.update({
      'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
    });

    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + userName])
    });
  }


  // 사용자가 그룹에 가입되어있는지 확인하는 코드
  Future<bool> isUserJoined(String groupId, String groupName,
      String userName) async {
    DocumentReference userDocRef = userCollection.doc(userName);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    List<dynamic> groups = await userDocSnapshot.data()['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('he');
      return true;
    }
    else {
      //print('ne');
      return false;
    }
  }

  Future<bool> isSecretRoom(String groupId) async {
    DocumentReference groupDocRef = groupCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    if (groupDocSnapshot.data().containsKey("roomPassword")) {
      return true;
    } else {
      return false;
    }
  }



  Future<bool> isSameRoomPassword(String groupId, String password) async {
    DocumentReference groupDocRef = groupCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    if (groupDocSnapshot.data().containsValue(password)) {
      return true;
    } else if (!groupDocSnapshot.data().containsValue(password)) {
      return false;
    }
  }

  Future<bool> hasFriendRequest(String senderName) async {
    DocumentReference userDocRef = userCollection.doc(userName);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.data().containsValue(senderName)) {
      return true;
    } else if (!userDocSnapshot.data().containsValue(senderName)) {
      return false;
    }
  }

  Future deleteGroupIfNoMembers(String groupId) async{
    DocumentReference groupDocRef = groupCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();


    List<dynamic> members = await groupDocSnapshot.data()['members'];
    if(members.isEmpty){

      await groupCollection.doc(groupId).delete();
    }
  }


  // 특정 사용자의 데이터를 얻어오기
  Future getUserData(String email) async {
    QuerySnapshot snapshot = await userCollection.where(
        'email', isEqualTo: email)
        .get(); //특정 이메일을 가지고있는 documents를 얻어옴
    print(snapshot.docs[0].data()); //documents의 첫번째 인덱스의 데이터를 출력
    return snapshot; //특정 이메일의 정보를 가지고있는 documents의 정보를 저장한 snapshot
  }

  //특정 사용자의 정보를 얻어 오기(snapshots()함수를 사용하면 데이터를 수정되자마자 바로 적용되어야하기때문에, StreamBuilder를 사용해야만 함.)
  getUserSnapshots() async {
    //
    return userCollection.doc(userName).snapshots();
  }

  // 메세지 전송
  sendMessage(String groupId, chatMessageData) {
    DatabaseService().groupCollection.doc(groupId).collection(
        'messages').add(chatMessageData);
    // message라는 collection을 특정 groupID의 document에 생성함과 동시에 message collection 내부에 새로운 document가 추가되고, 그 document내에
    //{ message: "", sender: "", time: 큰 정수자료형(long같은...) } 틀에다가 키에 맞는 값들이 추가된다.
    //chatMessageData에 대한 자세한부분은 sendMessage를 호출하는 코드가 있는 chat_page.dart를 확인하기 바란다.

    //groups의 특정 groupID내의 recentMessage/recentMessageSender/recentMessageTime 업데이트
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    }); //
  }

  sendMessageInFriendChat(String groupId, chatMessageData) {
    FirebaseFirestore.instance.collection('friendsChatGroup')
        .doc(groupId)
        .collection(
        'messages')
        .add(chatMessageData);
    // message라는 collection을 특정 groupID의 document에 생성함과 동시에 message collection 내부에 새로운 document가 추가되고, 그 document내에
    //{ message: "", sender: "", time: 큰 정수자료형(long같은...) } 틀에다가 키에 맞는 값들이 추가된다.
    //chatMessageData에 대한 자세한부분은 sendMessage를 호출하는 코드가 있는 chat_page.dart를 확인하기 바란다.

    //groups의 특정 groupID내의 recentMessage/recentMessageSender/recentMessageTime 업데이트
    FirebaseFirestore.instance.collection('friendsChatGroup')
        .doc(groupId)
        .update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    }); //
  }

  // 특정 그룹의 채팅 찾기
  getChats(String groupId) async {
    return FirebaseFirestore.instance.collection('groups').doc(groupId).collection(
        'messages').orderBy('time').snapshots();
  }

  getFriendChats(String groupId) async {
    return FirebaseFirestore.instance.collection('friendsChatGroup').doc(groupId)
        .collection(
        'messages').orderBy('time')
        .snapshots();
  }


  // 그룹 찾기
  searchByName(String groupName) {
    return groupCollection.where(
        'groupName', isEqualTo: groupName).getDocuments();
  }


  Future<bool> isChief(String participantName, String groupId) async {
    DocumentReference groupDocRef = groupCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    if (groupDocSnapshot.data()["admin"] == participantName) {
      return true;
    } else if (!(groupDocSnapshot.data()["admin"] == participantName)) {
      return false;
    }
  }


  Future deleteMembers(String groupId, String groupName, String userName) async {

    DocumentReference userDocRef = userCollection.doc(userName); //특정 uid로 명칭된 document의 주소를 userDocRef에 저장
    DocumentSnapshot userDocSnapshot = await userDocRef.get(); //특정 uid로 명칭된 document내에 저장된 데이터들을 얻어와서 userDocSnapshot에 저장
    DocumentReference groupDocRef = groupCollection.doc(groupId); //특정 groupId로 명칭된 doc 주소를 groupDocRef에 저장

    List<dynamic> groups = await userDocSnapshot.data()['groups'];
    //특정 유저의 데이터에서 groups라는 키를 통해 groups에 저장된 모든 값들을 배열 형태로 저장
    //쉽게 말하자면, 사용자가 속한 그룹들의 정보를 groups라는 배열에 저장하는 것이며, groups키 내의 값들은 groupID_방제목 형태로 저장되어있다.

    //그룹에서 맴버 삭제하는 코드
    if (groups.contains(groupId + '_' + groupName)) { //togglinGroupJoin함수의 매개변수로 들어온 groupId와 groupName이 특정 유저의 groups데이터에 존재한다면
      await userDocRef.update({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
        //groups에서 매개변수로로 들어온 그룹Id_그룹이름에 해당하는 데이터 삭제
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove([uid + '_' + userName])
        //groups에서 특정 gid로 명칭된 document안의 키값 중 members 내에 저장된 uid_userName 삭제
      });
    }
  }
}