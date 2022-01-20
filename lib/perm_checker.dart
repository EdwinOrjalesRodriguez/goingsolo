import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermsPage extends StatefulWidget {
  const PermsPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<PermsPage> createState() => _PermsPageState();
}

class _PermsPageState extends State<PermsPage> {
  var smsPerms = 0;//Where 0 is first ask and 1 is permanent disabled
  bool granted = false;

  Future _requestSMSPerms() async{
    await Permission.sms.request().then((status) {
      if(status.isGranted) {
        granted = true;
        //Nav home
      } else {
        smsPerms = status.isPermanentlyDenied ? 1 : 0;
      }
      setState(() {});
    });
    return granted;
  }

  _openSettingsWindow() async {
    await openAppSettings().then((_){
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: smsPerms == 0 ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'This app requires SMS permissions to properly run:',
            ),
            ElevatedButton(
              onPressed: (){
                _requestSMSPerms().then((status) {
                  if(status) {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                  }
                });
                //Navigator.pop(context, "UNO");
              },
              child: const Text('GRANT SMS PERMISSIONS'),
            ),
          ],
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left:20, right:20, bottom: 20),
              child: const Text(
                'SMS Permissions are disabled for this app. In order to use it, please open app settings and allow SMS permissions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (){
                _openSettingsWindow();
              },
              child: const Text('OPEN APP SETTINGS'),
            ),
            Container(
              margin: const EdgeInsets.only(top:20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.red
                ),
                onPressed: (){
                  _requestSMSPerms().then((value){
                    if(!granted) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('NO PERMISSIONS'),
                          content: const Text('SMS Permissions are still disabled. Please check settings and try again.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                    }
                  });
                },
                child: const Text('VERIFY AND CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}