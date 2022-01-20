import 'package:flutter/material.dart';

class AlertEditCreatePage extends StatefulWidget {
  const AlertEditCreatePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<AlertEditCreatePage> createState() => _AlertEditCreatePageState();
}

class _AlertEditCreatePageState extends State<AlertEditCreatePage> {

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'ALERT - EDIT/CREATE',
            ),
          ],
        ),
      ),
    );
  }
}