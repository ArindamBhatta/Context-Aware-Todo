import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo/features/auth/data/model/user_model.dart';

//SHA stands for Secure Hash Algorithm.
// The private signing key creates the digital signature on your APK.
// The certificate contains the corresponding public key and metadata.
// The SHA-1 is simply a fingerprint of that certificate.

//1. Debug SHA-1 → Used while developing locally.

// 2. Release SHA-1 → Used for the app you publish to the Play Store.
class GoogleAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: <String>['email', 'profile']);

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  UserModel? getCurrentUser() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }

    return UserModel(
      displayName: user.displayName ?? user.email ?? 'User',
      photoUrl: user.photoURL,
      email: user.email,
    );
  }

  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return false;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser != null;
  }

  Future<void> signOut() async {
    await Future.wait<void>(<Future<void>>[
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
