import 'dart:async';
import 'package:flutter/material.dart';
import 'package:going_solo/map_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'profile_login.dart';
import 'profile.dart';
import 'alert_select.dart';
import 'contacts.dart';
import 'mode_select.dart';
import 'notify_select.dart';
import 'settings.dart';
import 'perm_checker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'dart:math';
var cPPOOZ = false;
var loggedin = true;
var currentMode = "";
Location location = Location();
const defaultAvatarURL = 'https://i.imgur.com/scvQ6ro.png';
bool smsPermissions = false;
Widget _defaulthome = const MyHomePage(title: 'Going Solo');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var status = await Permission.sms.status;
  smsPermissions = status.isDenied ? false : true;
  await Firebase.initializeApp();
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
    if (user == null) {
      loggedin = false;
    }
  });
  //"AWAY FORM SCHOOL" MODE FUNC//
  const interval = Duration(seconds:10);
  Timer.periodic(interval, (Timer t) {
    //Executed on interval
    _awayFromHome();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if(!loggedin) {
      _defaulthome = const ProfileLoginPage(title: 'Going Solo');
    }
    if(!smsPermissions) {
      _defaulthome = const PermsPage(title: 'Permissions Required');
    }
    return MaterialApp(
      title: 'Going Solo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: _defaulthome,
      routes: <String, WidgetBuilder>{
        // Set routes for using the Navigator.
        '/home': (BuildContext context) => const MyHomePage(title: 'Going Solo'),
        '/login': (BuildContext context) => const ProfileLoginPage(title: 'Going Solo'),
        '/contacts' : (BuildContext context) => const ContactsPage(title: 'Contacts')
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isActive = false;
  bool loaded = false;
  var btnTxt = "OFF";
  var btnClr = Colors.grey;
  activeBtnOn(value){
    isActive = value;
    btnTxt = "ON";
    btnClr = Colors.green;
  }
  activeBtnOff(value){
    isActive = value;
    btnTxt = "OFF";
    btnClr = Colors.grey;
  }
  loadCheck() {
    _getActivate().then((value) {
      if(value) {
        activeBtnOn(value);
      } else {
        activeBtnOff(value);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("CURRENT MODE: " + currentMode);
    if(!loaded) {
      loadCheck();

      loaded = true;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'Update your profile settings',
          onPressed: (){
            FirebaseAuth.instance
                .authStateChanges()
                .listen((User? user) {
              if (user == null) {
                Navigator.popAndPushNamed(context, '/login');
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage(title: "Profile")),
                );
              }
            });
          }
        ),
        title: Text(widget.title),
        leadingWidth: 56,
        actions: [IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Manage App Configuration',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage(title: "Settings")),
            );
          },
        ),],
          centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    primary: btnClr,
                ),
                child: Container(
                  width: 175,
                  height: 175,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Text(
                    btnTxt,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                onPressed: () {
                  _toggleActivate().then((value) {
                    if(value) {
                      activeBtnOn(value);
                    } else {
                      activeBtnOff(value);
                    }
                  });
                  setState(() {});
                },
              ),
            ),
            OutlinedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ModeSelectPage(title: "Select Mode")),
                  );
                },
                child: const Text("SELECT MODE"),
            ),
            OutlinedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotifySelectPage(title: "Notify")),
                );
              },
              child: const Text("NOTIFY"),
            ),
            OutlinedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapViewPage(title: "MapTest")),
                );
              },
              child: const Text("SEND LOCATION"),
            ),
            /**OutlinedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertSelectPage(title: "Alerts")),
                );
              },
              child: const Text("ALERTS"),
            ),**/
            OutlinedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactsPage(title: "Contacts")),
                );
              },
              child: const Text("CONTACTS"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _toggleActivate() async{
  var finalStatus = false;
  await SharedPreferences.getInstance().then((value) {
    var status = value.getBool("gsActive");
    if(status == null) {
      finalStatus = true;
    } else {
      if(!status) {
        finalStatus = true;
      }
    }
    debugPrint("Setting gsActive to " + finalStatus.toString());
    value.setBool("gsActive", finalStatus);
  });
  return finalStatus;
}

Future<bool> _getActivate() async{
  var output = false;
  await SharedPreferences.getInstance().then((value) {
    var status = value.getBool("gsActive");
    if(status != null) {
      output = status;
    }
  });
  return output;
}

_awayFromHome() async{
  double distance = 0;
  var gsActive = await _getActivate();
  var latCPP = 34.0583116;
  var lngCPP = -117.8239615;
  if(gsActive) {
    await location.getLocation().then((value) {
      var myLat = value.latitude;
      var myLng = value.longitude;
      distance = calculateDistance(latCPP, lngCPP, myLat, myLng);
      if(distance > 16) {
        if(!cPPOOZ) {
          _sendsms("4085553324", "I'm outside my school area!");
          cPPOOZ = true;
        }
      }
    });
  }
}

double calculateDistance(lat1, lon1, lat2, lon2){
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p)/2 +
      c(lat1 * p) * c(lat2 * p) *
          (1 - c((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a));
}

_sendsms(phone, message) async{
  debugPrint("Sending alert to " + phone + "...");
  await telephony.sendSms(
      to: phone,
      message: message,
      statusListener: listener
  );
}

SendStatus listener (SendStatus status) {
  var smsFail = false;
  if (status.toString() == "SendStatus.SENT") {
  } else {
    smsFail = true;
  }
  return status;
}