import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:going_solo/notify_view.dart';
import 'package:going_solo/notify_edit_create.dart';
import 'notify_class.dart';

class NotifySelectPage extends StatefulWidget {
  const NotifySelectPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<NotifySelectPage> createState() => _NotifySelectPageState();
}

class _NotifySelectPageState extends State<NotifySelectPage> {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  var loaded = false;
  var notifyList = <Notify>[];
  bool noRecords = false;

  _refreshNotifyList() {
    var auth = FirebaseAuth.instance.currentUser;
    if(auth != null) {
      _getAllNotify().then((result) {
        notifyList = result;
        loaded = true;
        setState(() {});
      }).catchError((error) {
        debugPrint(error.toString());
      });
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  _NotifySelectPageState() {
    var cDB = FirebaseDatabase.instance.ref().child('users/' + uid + '/notify');
    cDB.onChildChanged.listen((event) {_refreshNotifyList();});
    cDB.onChildAdded.listen((event) {_refreshNotifyList();});
    cDB.onChildRemoved.listen((event) {_refreshNotifyList();});
    cDB.onChildMoved.listen((event) {_refreshNotifyList();});
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!loaded) {_refreshNotifyList();}
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
            notifyList.isEmpty ? const Text("No notify events found. Click below to add new."):
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: notifyList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        debugPrint("Click on contact: " + notifyList[index].name);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotifyViewPage(title: "Send Notify", notifyCard: notifyList[index], uID: uid)),
                        );
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
                                  notifyList[index].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text('"' + notifyList[index].message + '"')
                              ],
                            ),
                            const Spacer(),
                            notifyList[index].isConditional ? const Text("Auto") :
                            const Text("Manual"),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotifyEditCreatePage(title: "Add Notify"))
                  );
                },
                child: const Text('Add Notify'),
              ),
            ),
          ],
        ),
      )
    );
  }
}

Future _getAllNotify() async{
  var uid = FirebaseAuth.instance.currentUser!.uid;
  List<Notify> notify = <Notify>[];
  await FirebaseDatabase.instance.ref().child('users/' + uid + '/notify').once().then((result){
    if(result.snapshot.value != null) {
      final data = Map<String, dynamic>.from(result.snapshot.value as Map<dynamic, dynamic>);
      data.forEach((key, value) {
        debugPrint("got a record");
        //Key contains ID for each contact, we have to pass it to store it as a key under each contact's info set
        notify.add(Notify.fromRTDB(value, key));
      });
    }
  });
  //notify.sort((a,b) => a.name.compareTo(b.name));//This is standalone function, should not be assigned to variable
  return notify;
}