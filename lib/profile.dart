import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var userName = '';
  var userEmail = '';
  var userSignupDate = '';
  final uid = FirebaseAuth.instance.currentUser?.uid;

  _refreshProfile() {
    debugPrint("Fetching user profile info for " + uid!);
    FirebaseDatabase.instance.ref().child("users/" + uid!).once().then((record){
      userName = record.snapshot.child('name').value.toString();
      userEmail = record.snapshot.child('email').value.toString();
      userSignupDate = record.snapshot.child('signup_date').value.toString();
      setState(() {});
    }).catchError((error){
      debugPrint(error.toString());
    });
  }

  _ProfilePageState() {
    _refreshProfile();
    var cDB = FirebaseDatabase.instance.ref().child('users/' + uid!);
    cDB.onChildChanged.listen((event) {_refreshProfile();});
    cDB.onChildAdded.listen((event) {_refreshProfile();});
    cDB.onChildRemoved.listen((event) {_refreshProfile();});
    cDB.onChildMoved.listen((event) {_refreshProfile();});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Name: ' + userName,
            ),
            Text(
              'Email: ' + userEmail,
            ),
            Text(
              'Joined: ' + userSignupDate,
            ),
            ElevatedButton(
              onPressed: (){
                _signOut(context);
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _signOut(context) async {
  await FirebaseAuth.instance.signOut().then((_) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  });
}