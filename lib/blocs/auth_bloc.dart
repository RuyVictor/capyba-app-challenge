import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthBloc {
  static User? user;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  User? getUser() {
    return user;
  }

  Future<void> reloadUser() async {
    await user!.reload();
    user = auth.currentUser;
  }

  void setUser(User newUser) {
    user = newUser;
  }

  Future<void> createAccount(String name, email, password, XFile? profileImage) async {
    final User? isUser = (await auth.createUserWithEmailAndPassword(email: email, password: password)).user;
    if (isUser != null) {
      await isUser.updateDisplayName(name);
      if (profileImage != null) {
        final storageRef = storage.ref('/user_assets/'+ isUser.uid + '/profile_image');
        UploadTask uploadTask = storageRef.putFile(File(profileImage.path));
        String downloadURL = await (await uploadTask).ref.getDownloadURL();
        await isUser.updatePhotoURL(downloadURL);
      }
      await isUser.reload();
      user = auth.currentUser;
      print(user);
    }
  }
  Future<void> sendVerificationEmail() async {
    await user!.sendEmailVerification();
  }
  Future<void> changeProfileData(String newName, newEmail, XFile? profileImage) async {
    await user!.updateDisplayName(newName); // Altera a senha apenas se for autenticado
    await user!.updateEmail(newEmail);
    if (profileImage != null) {
      final storageRef = storage.ref('/user_assets/' + user!.uid + '/profile_image');
      UploadTask uploadTask = storageRef.putFile(File(profileImage.path));
      String downloadURL = await (await uploadTask).ref.getDownloadURL();
      await user!.updatePhotoURL(downloadURL);
    }
    await reloadUser();
  }
  Future<void> changePassword(String currentPassword, newPassword) async {
    final cred = EmailAuthProvider.credential(email: user!.email!, password: currentPassword);
    // Verifica a senha atual do usuário, em seguida é liberado para alteração.
    await user!.reauthenticateWithCredential(cred);
    await user!.updatePassword(newPassword);
  }
  Future<void> signIn(String email, password) async {
    final User? isUser = (await auth.signInWithEmailAndPassword(email: email, password: password)).user;
    if (isUser != null) {
      user = isUser;
    }
  }
  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await auth.signOut();
    user = null;
  }

  // Google Authentication

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      user = userCredential.user;
    }
  }
}