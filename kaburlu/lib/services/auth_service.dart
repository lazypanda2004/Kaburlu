import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

    List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '618190322619-9v9l3uqda2e6l8d8ejff2igmsuiem0q9.apps.googleusercontent.com',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
  signinwithgoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
    
  }
}
