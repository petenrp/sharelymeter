import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharelymeter/database/database.dart';
import 'package:sharelymeter/models/user.dart';

class AuthService {   
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CustomUser _userFromFirebaseUser(User user) {
    return user != null ? CustomUser(uid: user.uid) : null;
  }

  Stream<CustomUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
    //.map((User user) => _userFromFirebaseUser(user));
  }

  //get UID
  Future<String> getCurrentUID() async {
    return await _auth.currentUser.uid;
  }

  //get current user
  Future getCurrentUser() async {
    return await _auth.currentUser;
  }


  //signup with Email and password
  Future registerWithEmailAndPassword(String email, String password, String firstname, String lastname, String phonenumber) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      User user = result.user;

      //create a new document for the user with uid
      await DatabaseService(uid: user.uid).updateUserData(
        firstname,
        lastname,
        phonenumber,
        email,
      );

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //signin with Email and password
  Future<CustomUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //signout
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

}