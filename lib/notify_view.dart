import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'contacts_friend_class.dart';
import 'notify_edit_create.dart';
import 'package:flutter/material.dart';
import 'notify_class.dart';
import 'package:telephony/telephony.dart';
import 'package:location/location.dart';
final Telephony telephony = Telephony.instance;
final Location location = Location();

class NotifyViewPage extends StatefulWidget {
  const NotifyViewPage({Key? key, required this.title, required this.notifyCard, required this.uID}) : super(key: key);
  final String uID;
  final Notify notifyCard;
  final String title;
  @override
  State<NotifyViewPage> createState() => _NotifyViewPageState();
}

class _NotifyViewPageState extends State<NotifyViewPage> {
  var notifyName = "";
  var notifyMessage = "";
  var notifyDetailsTxt = "";
  var cIDList = [];
  var sendBtnTxt = "SEND";
  var sendBtnClr = Colors.blue;
  var latitude = "";
  var longitude = "";
  List<String> recipientList = [];
  List<Friend> contactList = <Friend>[];
  bool loadingState = false;
  bool sendLocation = false;
  bool requestCheckIn = false;
  bool isConditional = false;
  bool loaded = false;
  bool smsFail = false;
  bool mountedListener = false;

  Future _getRecipientList(uID, cIDList, message) async{
    var err = 0;
    var cleanphone = "";
    for (var cID in cIDList) {
      await _getPhoneNumberFromCID(uID, cID).then((phone) {
        cleanphone = phone;
        setState(() { });
      }).catchError((error) {
        debugPrint(error.toString());
      });
      await _sendSMS(message, cleanphone.toString().replaceAll(RegExp(r'[^0-9]'), '')).then((success) {
        if(success) {
          debugPrint("Delivered to " + cleanphone);
        } else {
          debugPrint("Fail to deliver to " + cleanphone);
          err++;
        }
        setState(() { });
      });
    }
    return err == 0 ? true : false;
  }

  Future _getPhoneNumberFromCID(uID, cID) async{
    var _phone = "";
    await FirebaseDatabase.instance.ref().child('users/' + uID + '/contacts/' + cID).once().then((result) {
      _phone = result.snapshot.child("phone").value.toString();
    }).catchError((error) {
      debugPrint(error.toString());
    });
    return _phone;
  }

  Future _sendSMS(message, phone) async{
    var pin = "";
    var lat = "";
    var long = "";
    if(sendLocation) {
      await location.getLocation().then((value) {
        lat = value.latitude.toString();
        long = value.longitude.toString();
        pin = "\nhttp://www.google.com/maps/place/" + lat + "," + long;
      });
    }
    debugPrint("Sending SMS to " + phone + "... ");
    await telephony.sendSms(
        to: phone,
        message: message + pin,
        statusListener: listener
    );
    setState(() {});
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

  Future _buildContactList(cIDList) async{
    contactList = <Friend>[];
    List<String> tmp = [];
    for (var cID in cIDList) {
      if(!tmp.contains(cID)) {
        tmp.add(cID);
        await _importContactCard(cID).then((contactCard) {
          contactList.add(contactCard);
        }).catchError((error) {
          debugPrint(error.toString());
        });
      }
    }
  }

  Future _refreshNotify(uID, nID) async{
      await FirebaseDatabase.instance.ref().child('users/' + uID + '/notify/' + nID).once().then((record){
      var fetchList = record.snapshot.child('cIDList').value as List;
      notifyDetailsTxt = "";
      notifyName = record.snapshot.child('name').value.toString();
      notifyMessage = record.snapshot.child('message').value.toString();
      sendLocation = record.snapshot.child('sendLocation').value as bool;
      requestCheckIn = record.snapshot.child('requestCheckIn').value as bool;
      isConditional = record.snapshot.child('isConditional').value as bool;
      cIDList = [];
      for (var cID in fetchList) {
        if(cID != null && !cIDList.contains(cID)) {
          cIDList.add(cID);
        }
      }

      Map<String, List> notifyDetailsList = {
        'sendLocation': [sendLocation, "Sends Location"],
        'requestCheckIn': [requestCheckIn, "Requests Check-In"],
      };
      var c = 0;
      notifyDetailsList.forEach((key, value) {
        if(value[0]) {
          notifyDetailsTxt += (c == 0) ? "[ " : ", ";
          notifyDetailsTxt += value[1];
          c++;
        }
      });
      notifyDetailsTxt += c > 0 ? " ]" : "";
    }).catchError((error){
      debugPrint(error.toString());
    });
    return cIDList;
  }

  Future setBtnState(delay, text, color, state) async{
    return Future.delayed(Duration(seconds: delay), () {
      sendBtnTxt = text;
      sendBtnClr = color;
      loadingState = state;
      setState(() {});
    });
  }

  _reload(uID, nID) {
    _refreshNotify(uID, nID).then((cIDList){
      _buildContactList(cIDList).then((_) {
        loaded = true;
        setState(() {});
      });
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
    var uID = widget.uID;
    var nID = widget.notifyCard.nID;
    var cDB = FirebaseDatabase.instance.ref().child('users/' + uID + '/notify/' + nID);
    if(!loaded) {
      _reload(uID, nID);
      if(!mountedListener) {
        cDB.onChildChanged.listen((event) {if(loaded){_reload(uID, nID);}});
        cDB.onChildAdded.listen((event) {if(loaded){_reload(uID, nID);}});
        cDB.onChildRemoved.listen((event) {if(loaded){_reload(uID, nID);}});
        mountedListener = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(notifyName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      primary: sendBtnClr,
                    ),
                    child: Container(
                      width: 175,
                      height: 175,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Text(
                        sendBtnTxt,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: loadingState ? () {} : () {
                      if(cIDList.isEmpty) {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("No Contact Selected"),
                            content: const Text("Can't send notify because there's no contact to send it to. Please edit and add a contact."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, "OK"); //Exits confirmation prompt
                                },
                                child: const Text("OK"),
                              )
                            ],
                          ),
                        );
                      } else {
                        //SEND SMS
                        setBtnState(0, "...SENDING...", Colors.blueGrey, true);
                        debugPrint("Attempting SMS Notify... Message: \"" + notifyMessage + "\"... RecipientList: " + cIDList.toString());
                        _getRecipientList(uID, cIDList, notifyMessage).then((value) {
                          debugPrint("finished! " + value.toString());
                          setBtnState(1, "SENT!", Colors.green, true).then((_){
                            setBtnState(4, "SEND", Colors.blue, false);
                          });
                        });
                      }
                    },
                  ),
                ),
                if(contactList.isNotEmpty)
                  ListTile(
                    onTap: () {
                    },
                    title: Container(
                      height: 50,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.indigo,
                                      backgroundImage: NetworkImage(contactList[0].avatarURL),
                                      radius: 25,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contactList[0].name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14
                                        ),
                                      ),
                                      Text(
                                        contactList[0].phone,
                                        style: const TextStyle(
                                            fontSize: 12
                                        ),
                                      )
                                    ],
                                  ),
                                ],),
                                if (contactList.length > 1)
                                  Row(children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 10, right: 10),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.indigo,
                                        backgroundImage: NetworkImage(contactList[1].avatarURL),
                                        radius: 25,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contactList[1].name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14
                                          ),
                                        ),
                                        Text(
                                          contactList[1].phone,
                                          style: const TextStyle(
                                              fontSize: 12
                                          ),
                                        )
                                      ],
                                    ),
                                  ],),
                              ],
                      ),
                    ),
                  ),
                if(contactList.length > 2)
                Container(
                  margin: const EdgeInsets.only(top:5),
                    child: Text("+" + (contactList.length - 2).toString() + " more")
                )
              ],
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                child: Text(
                  '"' + notifyMessage + '"',
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                notifyDetailsTxt,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.indigo
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top:10),
              child: ElevatedButton(
                onPressed: (){
                  var infoCard = Notify(
                    name: notifyName,
                    message: notifyMessage,
                    sendLocation: sendLocation,
                    requestCheckIn: requestCheckIn,
                    isConditional: isConditional,
                    nID: nID,
                    cIDList: cIDList
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotifyEditCreatePage(title: "Edit Notify", notifyCard: infoCard,))
                  );
                },
                child: const Text('Edit'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top:5),
              child: ElevatedButton(
                onPressed: (){
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Delete Notify'),
                        content: const Text('Are you sure you want to delete this notify?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'CANCEL'); //Exits confirmation prompt
                            },
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              //DELETE THIS RECORD AND GO BACK TO CONTACTS SCREEN
                              FirebaseDatabase.instance.ref().child('users/' + uID + '/notify/' + nID)
                                  .remove()
                                  .then((result) {
                                    setState(() {});
                                    //WE POP FIRST TO AVOID SCREEN FULL OF NULL VALUES ON NAVIGATION
                                    Navigator.pop(context); //Exits confirmation prompt
                                    Navigator.pop(context); //Back to contacts screen
                              }).catchError((error) {
                                debugPrint(error.toString());
                              });
                            },
                            child: const Text('DELETE'),
                          ),
                        ],
                      ),
                    );
                  },
                child: const Text("Delete"),
                style: ElevatedButton.styleFrom(
                    primary: Colors.red
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future _importContactCard(cID) async{
  var output = Friend(phone: "", avatarURL: "", type: "", email: "", cID: cID);
  var uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseDatabase.instance.ref().child('users/' + uid + '/contacts/' + cID).once().then((result){
    var data = Map<String, dynamic>.from(result.snapshot.value as Map<dynamic, dynamic>);
    output = Friend.fromRTDB(data, cID);
  });
  return output;
}