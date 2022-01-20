import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'notify_class.dart';
import 'contacts.dart';
import 'contacts_friend_class.dart';

class NotifyEditCreatePage extends StatefulWidget {
  const NotifyEditCreatePage({Key? key, required this.title, this.notifyCard = const Notify(
    name: "",
    message: "",
    sendLocation: false,
    requestCheckIn: false,
    isConditional: false,
    nID: "",
    cIDList: []
  )}) : super(key: key);
  final String title;
  final Notify notifyCard;
  @override
  State<NotifyEditCreatePage> createState() => _NotifyEditCreatePageState();
}

class _NotifyEditCreatePageState extends State<NotifyEditCreatePage> {
  var nameController = TextEditingController();
  var messageController = TextEditingController();
  var cIDList = [];
  List<Friend> contactList = <Friend>[];
  bool sendLocation = false;
  bool requestCheckIn = false;
  bool isConditional = false;
  bool loaded = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final _formKey = GlobalKey<FormState>();
    var nID = widget.notifyCard.nID;
    var btnTxt = nID.isEmpty ? "Add Notify" : "Update Notify";

    _updateContactList(cID) {
      if(!cIDList.contains(cID)){
        cIDList.add(cID);
        _importContactCard(cID).then((contactCard) {
          contactList.add(contactCard);
          setState(() {});
        }).catchError((error) {
          debugPrint(error.toString());
        });
      }
    }

    _removeCard(cID) {
      cIDList.remove(cID);
      contactList.removeWhere((item) => item.cID == cID);
      setState(() {});
    }

    if(!loaded) {
      var initName = widget.notifyCard.name.isEmpty ? "" : widget.notifyCard.name;
      var initMessage = widget.notifyCard.message.isEmpty ? "" : widget.notifyCard.message;
      nameController = TextEditingController(text: initName);
      messageController = TextEditingController(text: initMessage);
      sendLocation = widget.notifyCard.sendLocation ? true : false;
      requestCheckIn = widget.notifyCard.requestCheckIn ? true : false;
      isConditional = widget.notifyCard.isConditional ? true : false;
      if(widget.notifyCard.cIDList.isNotEmpty) {
        for (var cID in widget.notifyCard.cIDList) {
          _updateContactList(cID);
        }
      }
      loaded = true;
      setState(() {});
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left:35, right:20, top:20),
              child: Row(
                children: const [
                  Text("Contacts",
                    style: TextStyle(
                      fontSize: 18,
                      decoration: TextDecoration.underline
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: contactList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () {
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
                              ElevatedButton(
                                onPressed: (){
                                  _removeCard(contactList[index].cID);
                                },
                                child: const Text('Remove'),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),
            ),
            Row(
              children: [
                const Spacer(),
                FloatingActionButton.small(
                  tooltip: 'Add a new contact',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactsPage(title: "Select Contact", pickMode: true)),
                    ).then((value){
                      if(value != null) {
                        _updateContactList(value);
                      }
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                controller: nameController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notification Name:',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                controller: messageController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notification Message:',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: SwitchListTile(
                title: const Text("Send Location"),
                controlAffinity: ListTileControlAffinity.leading,
                value: sendLocation,
                onChanged: (value) {
                  sendLocation = value;
                  setState(() {});
                }
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: SwitchListTile(
                  title: const Text("Request Check-In"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: requestCheckIn,
                  onChanged: (value) {
                    requestCheckIn = value;
                    setState(() {});
                  }
              ),
            ),
            /**
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: SwitchListTile(
                  title: const Text("Send Automatically If..."),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isConditional,
                  onChanged: (value) {
                    isConditional = value;
                    setState(() {});
                  }
              ),
            ),**/
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                child: Text(btnTxt),
                onPressed: () {
                  if(cIDList.isEmpty) {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('No Contact Selected'),
                        content: const Text('You must add a contact to receive this notify.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'OK'); //Exits confirmation prompt
                            },
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );
                  } else {
                    if (_formKey.currentState!.validate()) {
                      var snkTxt = nID.isEmpty ? "Notify Added!" : "Notify Updated!";
                      var snkClickTxt = nID.isEmpty ? "Adding Notify..." : "Updating Notify...";
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(snkClickTxt)),
                      );
                      var uniqueHash = DateTime.now().millisecondsSinceEpoch;
                      var pathBase = 'users/' + uid + '/notify/';
                      var savePath = nID.isEmpty ? pathBase + uniqueHash.toString() : pathBase + nID;
                      FirebaseDatabase.instance.ref().child(savePath).set({
                        "name" : nameController.text,
                        "message" : messageController.text,
                        "sendLocation" : sendLocation,
                        "requestCheckIn" : requestCheckIn,
                        "isConditional" : isConditional,
                        "cIDList":  cIDList
                      }).then((value) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(snkTxt)),
                        );
                        var debugSuccessTxt = nID.isEmpty ? "Added notify " + uniqueHash.toString() : "Updated notify " + nID;
                        debugPrint(debugSuccessTxt);
                        Navigator.pop(context);
                        setState(() {});
                      }).catchError((error) {
                        var debugFailTxt = nID.isEmpty ? "add" : "update";
                        debugPrint("Failed to " + debugFailTxt + " to FireBase");
                        debugPrint(error.toString());
                      });
                    }
                  }
                },
              ),
            )
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