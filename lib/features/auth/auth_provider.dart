import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/firebase_collections.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/me_service.dart';
import '../../models/app_user_model.dart';
import '../../models/user_profile_model.dart';

class LifeDropAuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final MeService _meService = MeService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _setLoading(true);

      final credential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Registration failed');
      }

      // Optional old users collection
      final appUser = AppUserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: 'donor',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );

      await _firestoreService.setDocument(
        collection: FirebaseCollections.users,
        docId: firebaseUser.uid,
        data: appUser.toMap(),
      );

      // Main profile collection: me/{uid}
      final meProfile = UserProfileModel.empty(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        photo: firebaseUser.photoURL ?? '',
      );

      await _meService.createMeIfNotExists(meProfile);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoading(true);

      final credential = await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        final existingProfile = await _meService.getMe(firebaseUser.uid);

        if (existingProfile == null) {
          final meProfile = UserProfileModel.empty(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? email,
            phone: firebaseUser.phoneNumber ?? '',
            photo: firebaseUser.photoURL ?? '',
          );

          await _meService.createMeIfNotExists(meProfile);
        }
      }

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      _setLoading(true);

      final credential = await _authService.signInWithGoogle();
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Google login failed');
      }

      // Optional old users collection
      final appUser = AppUserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Life Drop User',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        role: 'donor',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUserIfNotExists(
        collection: FirebaseCollections.users,
        docId: firebaseUser.uid,
        data: appUser.toMap(),
      );

      // Main profile collection: me/{uid}
      final meProfile = UserProfileModel.empty(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        photo: firebaseUser.photoURL ?? '',
      );

      await _meService.createMeIfNotExists(meProfile);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      _setLoading(true);

      await _authService.sendPasswordResetEmail(email: email);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    isLoading = value;
    errorMessage = null;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'google-sign-in-cancelled':
        return 'Google sign in was cancelled.';
      case 'popup-closed-by-user':
        return 'Google sign in popup was closed.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using another sign-in method.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
