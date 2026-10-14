import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/login_type.dart';
import '../models/user.dart';

class UserService {
  Map<String, dynamic> data = {};

  firebase_auth.FirebaseAuth get _firebaseAuth =>
      firebase_auth.FirebaseAuth.instance;

  // Enhancement 2: Authenticate with DummyJSON and persist the returned user.
  Future<Map<String, dynamic>> loginUser(String username, String password) {
    return signIn(
      loginType: LoginType.dummyJson,
      username: username,
      password: password,
    );
  }

  // Enhancement 1: Single sign-in entry point for DummyJSON or Firebase.
  Future<Map<String, dynamic>> signIn({
    required LoginType loginType,
    required String username,
    required String password,
  }) async {
    if (loginType == LoginType.firebase) {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: username.trim(),
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw Exception('Firebase sign in failed.');
      }

      final userData = {
        'id': 0,
        'username': user.displayName ?? user.email?.split('@').first ?? '',
        'email': user.email ?? username.trim(),
        'firstName': user.displayName ?? '',
        'lastName': '',
        'gender': '',
        'image': user.photoURL ?? '',
        'accessToken': await user.getIdToken() ?? '',
        'refreshToken': user.refreshToken ?? '',
        'loginType': LoginType.firebase.storageValue,
        'firebaseUid': user.uid,
      };

      await saveUserData(userData, loginType: LoginType.firebase);
      return userData;
    }

    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      await saveUserData(data, loginType: LoginType.dummyJson);
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  // Enhancement 1: Create a Firebase account and save profile fields.
  Future<Map<String, dynamic>> createAccount({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String emailAddress,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: emailAddress.trim(),
      password: password,
    );
    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Firebase account creation failed.');
    }

    await firebaseUser.updateDisplayName(username.trim());

    final response = await http.post(
      Uri.parse('$host/users/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': fName,
        'lastName': lName,
        'age': age,
        'phone': contactNo,
        'username': username,
        'email': emailAddress,
      }),
    );

    final dummyUserData =
        response.statusCode == 200 || response.statusCode == 201
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    final userData = {
      'id': dummyUserData['id'] ?? 0,
      'username': username,
      'email': emailAddress,
      'firstName': fName,
      'lastName': lName,
      'gender': '',
      'image': '',
      'age': age,
      'contactNo': contactNo,
      'accessToken': await firebaseUser.getIdToken() ?? '',
      'refreshToken': firebaseUser.refreshToken ?? '',
      'loginType': LoginType.firebase.storageValue,
      'firebaseUid': firebaseUser.uid,
    };

    await saveUserData(userData, loginType: LoginType.firebase);
    return userData;
  }

  // Enhancements 1 and 3: Store authentication and profile/cart user data.
  Future<void> saveUserData(
    Map<String, dynamic> userData, {
    LoginType loginType = LoginType.dummyJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);

    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    await prefs.setString('loginType', loginType.storageValue);
    await prefs.setString('firebaseUid', userData['firebaseUid'] ?? '');
    await prefs.setInt('age', userData['age'] ?? 0);
    await prefs.setString('contactNo', userData['contactNo'] ?? '');

    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
      'loginType':
          prefs.getString('loginType') ?? LoginType.dummyJson.storageValue,
      'firebaseUid': prefs.getString('firebaseUid') ?? '',
      'age': prefs.getInt('age') ?? 0,
      'contactNo': prefs.getString('contactNo') ?? '',
    };
  }

  Future<LoginType> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    return LoginTypeExtension.fromStorageValue(
      prefs.getString('loginType') ?? LoginType.dummyJson.storageValue,
    );
  }

  Future<User> getUser() async {
    final userData = await getUserData();
    return User.fromJson(userData);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = LoginTypeExtension.fromStorageValue(
      prefs.getString('loginType') ?? LoginType.dummyJson.storageValue,
    );

    if (loginType == LoginType.firebase) {
      return _firebaseAuth.currentUser != null;
    }

    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // Enhancement 1: Update username locally and in Firebase display name.
  Future<void> updateUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = await getLoginType();

    if (loginType == LoginType.firebase) {
      await _firebaseAuth.currentUser?.updateDisplayName(username.trim());
    }

    await prefs.setString('username', username.trim());
    await prefs.setString('firstName', username.trim());
  }

  // Enhancement 1: Reset password for Firebase accounts using current password.
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null || user.email == null) {
      throw Exception(
        'Password reset is available for Firebase accounts only.',
      );
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);

    final token = await user.getIdToken(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token ?? '');
    await prefs.setString('token', token ?? '');
  }

  // Enhancement 1: Delete the Firebase account and clear the local session.
  Future<void> deleteAccount() async {
    final loginType = await getLoginType();

    if (loginType == LoginType.firebase) {
      await _firebaseAuth.currentUser?.delete();
    }

    await signOut();
  }

  // Enhancement 1: Clear the proper session/token for logout.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = await getLoginType();

    if (loginType == LoginType.firebase) {
      await _firebaseAuth.signOut();
    }

    await prefs.clear();
  }

  Future<void> logout() => signOut();
}
