import 'package:firebase_database/firebase_database.dart';
import 'package:going_solo/main.dart';
import 'contacts_edit_create.dart';
import 'package:flutter/material.dart';
import 'contacts_friend_class.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({Key? key, required this.title, required this.contactDetails, required this.uID}) : super(key: key);
  final String uID;
  final Friend contactDetails;
  final String title;
  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  var contactName = "";
  var contactPhone = "";
  var contactEmail = "";
  var contactAvatarURL = defaultAvatarURL;
  var popped = false;
  bool loaded = false;

  _refreshProfile(uID, cID) {
    FirebaseDatabase.instance.ref().child('users/' + uID + '/contacts/' + cID).once().then((record){
      contactName = record.snapshot.child('name').value.toString();
      contactPhone = record.snapshot.child('phone').value.toString();
      contactEmail = record.snapshot.child('email').value.toString();
      contactAvatarURL = record.snapshot.child('avatarURL').value.toString();
      loaded = true;
      setState(() {});
    }).catchError((error){
      debugPrint(error);
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
    var cID = widget.contactDetails.cID;
    if(!loaded) {_refreshProfile(uID, cID);}
    var cDB = FirebaseDatabase.instance.ref().child('users/' + uID + '/contacts/' + cID);
    cDB.onChildChanged.listen((event) {_refreshProfile(uID, cID);});
    var theEMAIL = contactEmail.isEmpty ? "[None]" : contactEmail;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            contactAvatarURL == defaultAvatarURL ? const Image(image: AssetImage('assets/defaultAvatar.png')) : Image(image: NetworkImage(contactAvatarURL)),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                  contactName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                "Phone: " + contactPhone,
                style: const TextStyle(
                    fontSize: 15,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                "Email: " + theEMAIL,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top:10),
              child: ElevatedButton(
                onPressed: (){
                  var infoCard = Friend(
                    name: contactName,
                    phone: contactPhone,
                    avatarURL: contactAvatarURL,
                    type: "Mobile",
                    email: contactEmail,
                    cID: cID,
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactsEditCreatePage(title: "Edit Contact", contactCard: infoCard,))
                  );
                },
                child: const Text('Edit'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top:5),
              child: ElevatedButton(
                onPressed: (){showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete Contact'),
                    content: const Text('Are you sure you want to delete this contact?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'CANCEL'); //Exits confirmation prompt
                          },
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          //WE POP FIRST TO AVOID SCREEN FULL OF NULL VALUES ON NAVIGATION
                          Navigator.pop(context); //Exits confirmation prompt
                          Navigator.pop(context); //Back to contacts screen
                          //DELETE THIS RECORD AND GO BACK TO CONTACTS SCREEN
                          FirebaseDatabase.instance.ref().child('users/' + uID + '/contacts/' + cID)
                              .remove()
                              .then((result) {
                              }).catchError((error) {
                                debugPrint(error.toString());
                          });
                        },
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                );},
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