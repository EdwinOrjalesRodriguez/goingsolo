import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:going_solo/main.dart';
import 'contacts_friend_class.dart';

class ContactsEditCreatePage extends StatefulWidget {
  const ContactsEditCreatePage({Key? key, required this.title, this.contactCard = const Friend(name: "", phone: "", email: "", avatarURL: "", type: "", cID: "")}) : super(key: key);
  final String title;
  final Friend contactCard;
  @override
  State<ContactsEditCreatePage> createState() => _ContactsEditCreatePageState();
}

class _ContactsEditCreatePageState extends State<ContactsEditCreatePage> {
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
    var initName = widget.contactCard.name.isEmpty ? "" : widget.contactCard.name;
    var initPhone = widget.contactCard.phone.isEmpty ? "" : widget.contactCard.phone;
    var initEmail = widget.contactCard.email.isEmpty ? "" : widget.contactCard.email;
    var initAvatarURL = widget.contactCard.avatarURL.isEmpty ? "" : widget.contactCard.avatarURL;
    var cID = widget.contactCard.cID;
    var nameController = TextEditingController(text: initName);
    var phoneController = TextEditingController(text: initPhone);
    var emailController = TextEditingController(text: initEmail);
    var avatarController = TextEditingController(text: initAvatarURL);
    var btnTxt = cID.isEmpty ? "Add Contact" : "Update Contact";
    var snkTxt = cID.isEmpty ? "Contact Added!" : "Contact Updated!";
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    labelText: 'Name:',
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
                  controller: phoneController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone:',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      //return 'This field is required';
                    }
                    return null;
                  },
                  controller: emailController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email:',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      //return 'This field is required';
                    }
                    return null;
                  },
                  controller: avatarController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'AvatarURL:',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  child: Text(btnTxt),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saving Contact...')),
                    );
                    if (_formKey.currentState!.validate()) {
                      var uniqueHash = DateTime.now().millisecondsSinceEpoch;
                      var submitAvatar = avatarController.text.isEmpty ? defaultAvatarURL : avatarController.text;
                      var pathBase = 'users/' + uid + '/contacts/';
                      var savePath = cID.isEmpty ? pathBase + uniqueHash.toString() : pathBase + cID;
                      FirebaseDatabase.instance.ref().child(savePath).set({
                        "name" : nameController.text,
                        "phone" : phoneController.text,
                        "email" : emailController.text,
                        "avatarURL" : submitAvatar,
                        "type" : "Mobile"
                      }).then((value) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(snkTxt)),
                        );
                        var debugSuccessTxt = cID.isEmpty ? "Added contact " + uniqueHash.toString() : "Updated contact " + cID;
                        debugPrint(debugSuccessTxt);
                        Navigator.pop(context);
                      }).catchError((error) {
                        var debugFailTxt = cID.isEmpty ? "add" : "update";
                        debugPrint("Failed to " + debugFailTxt + " to FireBase");
                        debugPrint(error.toString());
                      });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}