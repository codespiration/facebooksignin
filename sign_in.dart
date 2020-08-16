import 'package:connexionvideo/signed_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool userHasTouchId;
  String email, password;
  bool _useTouchId = false;

  @override
  void initState() {
    super.initState();
    getSecureStorage();
  }

  void getSecureStorage() async {
    final isUsingBio = await storage.read(key: 'usingBiometric');
    setState(() {
      userHasTouchId = isUsingBio == 'true';
    });
  }

  void authenticate() async {
    final canCheck = await auth.canCheckBiometrics;

    if (canCheck) {
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          // Face ID.
          final authenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Enable Face ID to sign in more easily');
          if (authenticated) {
            final userStoredEmail = await storage.read(key: 'email');
            final userStoredPassword = await storage.read(key: 'password');

            _signIn(em: userStoredEmail, pw: userStoredPassword);
          }
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          // Touch ID.
        }
      }
    } else {
      print('cant check');
    }
  }

  void _signIn({String em, String, pw}) {
    _auth
        .signInWithEmailAndPassword(email: em, password: pw)
        .then((authResult) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return SignedInPage(
          user: authResult.user,
          wantsTouchId: _useTouchId,
          password: password,
        );
      }));
    }).catchError((err) {
      print(err.code);
      if (err.code == 'ERROR_WRONG_PASSWORD') {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('The password was incorrect, please try again'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: <Widget>[
              Text(
                'SIGN IN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                onChanged: (textVal) {
                  setState(() {
                    email = textVal;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.white,
                  )),
                  hintText: 'Enter Email',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  focusColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                onChanged: (textVal) {
                  setState(() {
                    password = textVal;
                  });
                },
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.white,
                  )),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  focusColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              userHasTouchId
                  ? InkWell(
                      onTap: () => authenticate(),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.purple,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            FontAwesomeIcons.fingerprint,
                            size: 30,
                          )),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          activeColor: Colors.orange,
                          value: _useTouchId,
                          onChanged: (newValue) {
                            setState(() {
                              _useTouchId = newValue;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Use Touch ID',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        )
                      ],
                    ),
              SizedBox(
                height: 12.0,
              ),
              InkWell(
                onTap: () {
                  _signIn(em: email, pw: password);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 34.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ),
                  ),
                  child: Text(
                    'LOG IN',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: Icon(
                      FontAwesomeIcons.facebookF,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(
                    width: 38.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: Icon(
                      FontAwesomeIcons.twitter,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'FORGOT PASSWORD?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(30.0),
          color: Colors.black.withOpacity(0.2),
          child: Text(
            'DON\'T HAVE AN ACCOUNT? SIGN UP',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
