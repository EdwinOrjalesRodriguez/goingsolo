import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:going_solo/main.dart';
import 'mode_class.dart';

class ModeSelectPage extends StatefulWidget {
  const ModeSelectPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ModeSelectPage> createState() => _ModeSelectPageState();
}

class _ModeSelectPageState extends State<ModeSelectPage> {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  var loaded = false;
  var modeList = <Mode>[];
  bool noRecords = false;

  _refreshModeList() {
    var auth = FirebaseAuth.instance.currentUser;
    if(auth != null) {
      _getAllMode().then((result) {
        modeList = result;
        loaded = true;
        setState(() {});
      }).catchError((error) {
        debugPrint(error.toString());
      });
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  _ModeSelectPageState() {
    var cDB = FirebaseDatabase.instance.ref().child('users/' + uid + '/mode');
    cDB.onChildChanged.listen((event) {_refreshModeList();});
    cDB.onChildAdded.listen((event) {_refreshModeList();});
    cDB.onChildRemoved.listen((event) {_refreshModeList();});
    cDB.onChildMoved.listen((event) {_refreshModeList();});
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!loaded) {_refreshModeList();}
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: !loaded ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Loading...")
              ],
            ),
          ) :
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              modeList.isEmpty ? const Text("No mode events found. Click below to add new."):
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: modeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () {
                          currentMode = modeList[index].mID;
                          debugPrint("Mode set: " + modeList[index].mID);
                          Navigator.pop(context);
                        },
                        title: Container(
                          height: 50,
                          margin: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    modeList[index].name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text('"' + modeList[index].description + '"')
                                ],
                              ),
                              const Spacer(),
                              const Text("Active")
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom:20),
                child: ElevatedButton(
                  onPressed: (){
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Function Disabled'),
                        content: const Text('This functionality is not currently available.'),
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
                  },
                  child: const Text('Add Mode'),
                ),
              ),
            ],
          ),
        )
    );
  }
}

Future _getAllMode() async{
  var uid = FirebaseAuth.instance.currentUser!.uid;
  List<Mode> mode = <Mode>[];
  await FirebaseDatabase.instance.ref().child('users/' + uid + '/mode').once().then((result){
    if(result.snapshot.value != null) {
      final data = Map<String, dynamic>.from(result.snapshot.value as Map<dynamic, dynamic>);
      data.forEach((key, value) {
        //Key contains ID for each contact, we have to pass it to store it as a key under each contact's info set
        mode.add(Mode.fromRTDB(value, key));
      });
    }
  });
  //mode.sort((a,b) => a.name.compareTo(b.name));//This is standalone function, should not be assigned to variable
  return mode;
}