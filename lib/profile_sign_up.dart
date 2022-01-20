import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileSignUpPage extends StatefulWidget {
  const ProfileSignUpPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ProfileSignUpPage> createState() => _ProfileSignUpPageState();
}

class _ProfileSignUpPageState extends State<ProfileSignUpPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Center(
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
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          ),
                        )
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        controller: emailController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email:',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password:'
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        controller: nameController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name:'
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Sign Up'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registering new account...')),
                          );
                          debugPrint("Processing sign up for  " + nameController.text + "...");
                          FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          ).then((value) {
                            debugPrint("Sign up successful!");
                            FirebaseAuth.instance
                                .userChanges()
                                .listen((User? user) {
                              if (user == null) {
                                debugPrint('Signed up, but unable to retrieve user');
                              } else {
                                final userID = user.uid;
                                var timeStampRaw = DateTime.now();
                                var timeStampFormatted = DateFormat('MM-dd-yyyy').format(timeStampRaw);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Creating user profile...')),
                                );
                                FirebaseDatabase.instance.ref().child("users/" + userID).set(
                                    {
                                      "name" : nameController.text,
                                      "uid" : userID,
                                      "email" : emailController.text,
                                      "signup_date" : timeStampFormatted.toString()
                                    }
                                ).then((value) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Signed up successfully!')),
                                  );
                                  debugPrint("Profile created successfully");
                                  Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                                }).catchError((error) {
                                  debugPrint("Profile creation failed:");
                                  debugPrint(error.toString());
                                });
                              }
                            });
                          }).catchError((error) {
                            debugPrint("Sign up failed:");
                            debugPrint(error.toString());
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}