import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:going_solo/contact_view.dart';
import 'package:going_solo/contacts_edit_create.dart';
import 'contacts_friend_class.dart';
import 'package:telephony/telephony.dart';
final Telephony telephony = Telephony.instance;

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key, required this.title, this.pickMode = false, this.latitude = "", this.longitude = ""}) : super(key: key);
  final String latitude;
  final String longitude;
  final bool pickMode;
  final String title;
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  var loaded = false;
  var contactList = <Friend>[];
  var sendBtnTxt = "SEND";
  var sendBtnClr = Colors.blue;
  var activeTile = 0;
  bool noRecords = false;
  bool loadingState = false;
  bool smsFail = false;

  _ContactsPageState() {
    var cDB = FirebaseDatabase.instance.ref().child('users/' + uid + '/contacts');
    if(!loaded) {_refreshContactList();} else {
      cDB.onChildChanged.listen((event) {_refreshContactList();});
      cDB.onChildAdded.listen((event) {_refreshContactList();});
      cDB.onChildRemoved.listen((event) {_refreshContactList();});
      cDB.onChildMoved.listen((event) {_refreshContactList();});
    }
  }

  Future setBtnState(delay, text, color, state) async{
    return Future.delayed(Duration(seconds: delay), () {
      sendBtnTxt = text;
      sendBtnClr = color;
      loadingState = state;
      setState(() {});
    });
  }

  Future<bool> _sendPin(latitude, longitude, phone) async{
    smsFail = false;
    var pin = "http://www.google.com/maps/place/"+latitude+","+longitude;
    debugPrint("Sending pin to " + phone + "...");
    await telephony.sendSms(
        to: phone,
        message: pin,
        statusListener: listener
    );
    return smsFail ? false : true;
  }

  SendStatus listener (SendStatus status) {
    if (status.toString() == "SendStatus.SENT") {
    } else {
      smsFail = true;
    }
    setState(() {});
    return status;
  }

  _refreshContactList() {
    _getAllContact().then((result) {
      contactList = result;
      loaded = true;
      setState(() {});
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {

    if(!loaded) {_refreshContactList();}

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: !loaded ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Loading...")
          ],
        ),
      ) :
      contactList.isEmpty ? const Text("No contacts found. Click below to add new."):
      ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: contactList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                if(widget.latitude.isEmpty && widget.longitude.isEmpty) {
                  debugPrint("Click on contact: " + contactList[index].name);
                  if(widget.pickMode) {
                    Navigator.pop(context, contactList[index].cID);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactsView(title: "Contact Details", contactDetails: contactList[index], uID: uid)),
                    ).then((_) {
                      loaded = false;
                      setState(() {});
                    });
                  }
                }
              },
              title: Container(
                height: 50,
                margin: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        backgroundImage: NetworkImage(contactList[index].avatarURL),
                        radius: 25,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contactList[index].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(contactList[index].phone)
                      ],
                    ),
                    const Spacer(),
                    (widget.latitude.isNotEmpty && widget.longitude.isNotEmpty) ? ElevatedButton(
                      onPressed: (){
                        if(!loadingState) {
                          activeTile = index;
                          setBtnState(0, "SENDING", Colors.blueGrey, true);
                          _sendPin(widget.latitude, widget.longitude, contactList[index].phone.toString().replaceAll(RegExp(r'[^0-9]'), '')).then((result){
                            debugPrint(result? "Pin delivered" : "Unable to deliver pin");
                            setBtnState(1, "SENT!", Colors.green, true).then((_){
                              setBtnState(4, "SEND", Colors.blue, false).then((_){
                                Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                              });
                            });
                          });
                        }
                      },
                      child: Text(activeTile == index ? sendBtnTxt : "SEND"),
                      style: ElevatedButton.styleFrom(
                          primary: activeTile == index ? sendBtnClr : Colors.blue
                      ),
                    ) :
                    Text(contactList[index].type),
                  ],
                ),
              ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new contact',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactsEditCreatePage(title: "Add Contact"))
          ).then((result) {
            loaded = false;
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future _getAllContact() async{
  var uid = FirebaseAuth.instance.currentUser!.uid;
  List<Friend> friends = <Friend>[];
  await FirebaseDatabase.instance.ref().child('users/' + uid + '/contacts').once().then((result){
    final data = Map<String, dynamic>.from(result.snapshot.value as Map<dynamic, dynamic>);
    data.forEach((key, value) {
      //Key contains ID for each contact, we have to pass it to store it as a key under each contact's info set
      friends.add(Friend.fromRTDB(value, key));
    });
  });
  friends.sort((a,b) => a.name.compareTo(b.name));//This is standalone function, should not be assigned to variable
  return friends;
}