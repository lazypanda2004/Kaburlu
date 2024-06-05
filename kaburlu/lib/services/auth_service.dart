import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

    List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  clientId: '618190322619-9v9l3uqda2e6l8d8ejff2igmsuiem0q9.apps.googleusercontent.com',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
  // google sign-in
  signinwithgoogle() async {
    // begin sign-in process
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // obtain auth details from request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // sign-in user with credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
    
  }
}
