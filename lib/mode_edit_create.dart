import 'package:flutter/material.dart';

class NotifyEditCreate extends StatefulWidget {
  const NotifyEditCreate({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<NotifyEditCreate> createState() => _NotifyEditCreateState();
}

class _NotifyEditCreateState extends State<NotifyEditCreate> {
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
              'MODE EDIT/CREATE',
            ),
          ],
        ),
      ),
    );
  }
}