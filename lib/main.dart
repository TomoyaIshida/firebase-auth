import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(title: 'Firebase Auth'),
    );
  }
}

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<SignInPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleCurrentUser = _googleSignIn.currentUser;
    try {
      if (googleCurrentUser == null) googleCurrentUser = await _googleSignIn.signInSilently();
      if (googleCurrentUser == null) googleCurrentUser = await _googleSignIn.signIn();
      if (googleCurrentUser == null) return null;

      GoogleSignInAuthentication googleAuth = await googleCurrentUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void transitionNextPage(FirebaseUser user) {
    if (user == null) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        NextPage(userData: user)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'images/btn_google_light_normal_ios.png',
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color:Color.fromRGBO(68, 68, 76, .8),
                        ),
                      ),
                      padding: EdgeInsets.only(left: 5.0),
                    ),
                  ],
                ),
                onPressed: () {
                  _handleSignIn()
                      .then((FirebaseUser user) =>
                      transitionNextPage(user)
                  )
                      .catchError((e) => print(e));
                },
              ),
            ]
        ),
      ),
    );
  }
}

class NextPage extends StatefulWidget {
  FirebaseUser userData;

  NextPage({Key key, this.userData}) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState(userData);
}

class _NextPageState extends State<NextPage> {
  FirebaseUser userData;
  String name = "";
  String email;
  String photoUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  _NextPageState(FirebaseUser userData) {
    this.userData = userData;
    this.name = userData.displayName;
    this.email = userData.email;
    this.photoUrl = userData.photoUrl;
  }

  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(this.photoUrl),
              Text(this.name,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(this.email,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                padding: EdgeInsets.all(5.0),
                child: Text('Sign Out',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color:Color.fromRGBO(68, 68, 76, .8)
                  ),
                ),
                onPressed: () {
                  _handleSignOut().catchError((e) => print(e));
                },
              ),
            ]),
      ),
    );
  }
}
