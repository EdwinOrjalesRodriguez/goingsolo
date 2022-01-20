import 'package:flutter/material.dart';

class AlertManualEditPage extends StatefulWidget {
  const AlertManualEditPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<AlertManualEditPage> createState() => _AlertManualEditPageState();
}

class _AlertManualEditPageState extends State<AlertManualEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'ALERT - MANUAL: EDIT',
            ),
          ],
        ),
      ),
    );
  }
}