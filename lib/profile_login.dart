import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_sign_up.dart';

class ProfileLoginPage extends StatefulWidget {
  const ProfileLoginPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ProfileLoginPage> createState() => _ProfileLoginPageState();
}

class _ProfileLoginPageState extends State<ProfileLoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              flex: 40,
              child: Image(
                image: NetworkImage('https://c4.wallpaperflare.com/wallpaper/280/591/780/wildlife-fallen-leaves-landscape-forest-wallpaper-preview.jpg'),
              ),
            ),
            Expanded(
              flex: 60,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                    child: TextField(
                      controller: emailController,
                      obscureText: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email:'
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password:'
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: const Text(
                        'Forgot Password?',
                      style: TextStyle(
                        color: Colors.red
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('Log In'),
                    onPressed: () {
                      FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text
                      ).then((value) {
                        debugPrint("Login successful for " + emailController.text);
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                      }).catchError((error) {
                        debugPrint("Login failed for " + emailController.text);
                        debugPrint(error.toString());
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Sign Up'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileSignUpPage(title: "Sign Up")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.indigo
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}