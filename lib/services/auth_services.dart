import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthServices {
  // Get the instance of Firebase Auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get the current user
  User? getCurrentUser() => _firebaseAuth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'An error occurred during sign-in',
      );
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email, String password, String name) async {
  try {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 👇 Set the display name after account creation
    await userCredential.user?.updateDisplayName(name);
    await userCredential.user?.reload();

    // Send verification email
    await _sendVerificationEmail();

    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw FirebaseAuthException(
      code: e.code,
      message: e.message ?? 'An error occurred during sign-up',
    );
  }
}


  // Send verification email using Firebase Auth
  Future<void> _sendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
      } catch (e) {
        throw Exception('Failed to send verification email: $e');
      }
    }
  }

  // Verify email (check if user is verified)
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload(); // Refresh user data
      return user.emailVerified;
    }
    return false;
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await _sendVerificationEmail();
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign-in was cancelled',
        );
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Google sign-in failed',
      );
    }
  }

  // Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Apple sign-in failed',
      );
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Failed to send password reset email',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Failed to sign out',
      );
    }
  }
}
