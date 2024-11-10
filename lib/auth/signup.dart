// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:renty/styles/stylesauth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    super.initState();
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return users
        .add({
          'name': _name.text, // Le nom de l'utilisateur
          'email': _email.text, // L'email de l'utilisateur
          'phone': _phone.text, // Le numéro de téléphone de l'utilisateur
          'password': _password.text,
          'confpassword': _confirmPassword.text
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> _registerWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );
        addUser();
        // await FirebaseFirestore.instance.collection('users').add({
        //   'name': _name.text, // Le nom de l'utilisateur
        //   'email': _email.text, // L'email de l'utilisateur
        //   'phone': _phone.text, // Le numéro de téléphone de l'utilisateur
        //   'password': _password,
        //   'confpassword': _confirmPassword
        // });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
    //  if (_formKey.currentState!.validate()) {
    //     try {
    //       // Créer un utilisateur avec email et mot de passe
    //       UserCredential userCredential =
    //           await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //         email: _email.text,
    //         password: _password.text,
    //       );

    //       // Ajouter les données de l'utilisateur à Firestore
    //       await FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(userCredential.user?.uid)
    //           .set({
    //         'name': _name.text, // Le nom de l'utilisateur
    //         'email': _email.text, // L'email de l'utilisateur
    //         'phone': _phone.text, // Le numéro de téléphone de l'utilisateur
    //         'password': _password,
    //         'confpassword': _confirmPassword
    //       });

    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Compte créé avec succès!')),
    //       );
    //     } catch (e) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text(e.toString())),
    //       );
    //     }
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              kLargeSpacingHeight,
              Text("Create Account",
                  style: kTitleTextStyle, textAlign: TextAlign.center),
              kSpacingHeight,
              Text("Create a new account",
                  style: kSubtitleTextStyle, textAlign: TextAlign.center),
              kLargeSpacingHeight,
              TextFormField(
                controller: _name,
                decoration:
                    kInputDecoration(labelText: 'Name', icon: Icons.person),
                style: kInputTextStyle,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your name';
                  return null;
                },
              ),
              kSpacingHeight,
              TextFormField(
                controller: _email,
                decoration:
                    kInputDecoration(labelText: 'Email', icon: Icons.email),
                style: kInputTextStyle,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@'))
                    return 'Please enter a valid email';
                  return null;
                },
              ),
              kSpacingHeight,
              TextFormField(
                controller: _phone,
                decoration:
                    kInputDecoration(labelText: 'Phone', icon: Icons.phone),
                style: kInputTextStyle,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty || value.length < 8)
                    return 'Please enter a valid phone number';
                  return null;
                },
              ),
              kSpacingHeight,
              TextFormField(
                controller: _password,
                decoration:
                    kInputDecoration(labelText: 'Password', icon: Icons.lock),
                style: kInputTextStyle,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              kSpacingHeight,
              TextFormField(
                controller: _confirmPassword,
                decoration: kInputDecoration(
                    labelText: 'Confirm Password', icon: Icons.lock),
                style: kInputTextStyle,
                obscureText: true,
                validator: (value) {
                  if (value != _password.text) return 'Passwords do not match';
                  return null;
                },
              ),
              kLargeSpacingHeight,
              ElevatedButton(
                onPressed: _registerWithEmailAndPassword,
                child: Text('CREATE ACCOUNT'),
                style: kButtonStyle,
              ),
              kSpacingHeight,
              Center(
                child: TextButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, "Login");
                  },
                  child: Text("Already have an account? Login"),
                ),
              ),
              kSpacingHeight,
            ],
          ),
        ),
      ),
    );
  }
}
