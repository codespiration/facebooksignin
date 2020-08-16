import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';

class SignedInPage extends StatefulWidget {
  final FirebaseUser user;
  final bool wantsTouchId;
  final String password;

  SignedInPage(
      {@required this.user, @required this.wantsTouchId, this.password});

  @override
  _SignedInPageState createState() => _SignedInPageState();
}

class _SignedInPageState extends State<SignedInPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (widget.wantsTouchId) {
      authenticate();
    }
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
            storage.write(key: 'email', value: widget.user.email);
            storage.write(key: 'password', value: widget.password);
            storage.write(key: 'usingBiometric', value: 'true');
          }
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          // Touch ID.
        }
      }
    } else {
      print('cant check');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Welcome ${widget.user.email}',
                  style: TextStyle(fontSize: 24.0),
                ),
                FlatButton(
                  child: Text('Click to authenticate'),
                  onPressed: () {
                    authenticate();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
