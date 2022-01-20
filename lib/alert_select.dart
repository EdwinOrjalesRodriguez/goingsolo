import 'package:flutter/material.dart';

class AlertSelectPage extends StatefulWidget {
  const AlertSelectPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<AlertSelectPage> createState() => _AlertSelectPageState();
}

class _AlertSelectPageState extends State<AlertSelectPage> {
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
              'ALERT - SELECT',
            ),
          ],
        ),
      ),
    );
  }
}