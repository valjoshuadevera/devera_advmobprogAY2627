import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';

class ChatService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _chatRoomsCollection =>
      _firestore.collection('chat_rooms');

  // Enhancement 1: Persist Firebase users so they can appear in the chat list.
  Future<void> saveCurrentUserDocument({
    String? username,
    String? firstName,
    String? lastName,
    String? contactNo,
    int? age,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null || user.email == null) {
      return;
    }

    final displayName = username?.trim().isNotEmpty == true
        ? username!.trim()
        : user.displayName ?? user.email!.split('@').first;

    await _usersCollection.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': displayName,
      'username': displayName,
      'firstName': firstName ?? displayName,
      'lastName': lastName ?? '',
      'contactNo': contactNo ?? '',
      'age': age ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateCurrentUserName(String username) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return;
    }

    await _usersCollection.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': username.trim(),
      'username': username.trim(),
      'firstName': username.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteCurrentUserDocument() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return;
    }

    await _usersCollection.doc(user.uid).delete();
  }

  // Enhancement 1: Retrieve registered users while excluding the signed-in user.
  Stream<List<Map<String, dynamic>>> getRegisteredUsers() {
    final currentUid = _firebaseAuth.currentUser?.uid;

    return _usersCollection.snapshots().map((snapshot) {
      final users = snapshot.docs.where((doc) => doc.id != currentUid).map((
        doc,
      ) {
        final data = doc.data();
        return {
          ...data,
          'uid': data['uid'] ?? doc.id,
          'email': data['email'] ?? '',
          'name': data['name'] ?? data['username'] ?? '',
        };
      }).toList();

      users.sort(
        (a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo(
          (b['name'] ?? '').toString().toLowerCase(),
        ),
      );

      return users;
    });
  }

  Future<String?> getUserUidByEmail(String email) async {
    final snapshot = await _usersCollection
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final data = snapshot.docs.first.data();
    return data['uid'] ?? snapshot.docs.first.id;
  }

  String getChatRoomId(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();
    return ids.join('_');
  }

  // Enhancement 3: Send messages into deterministic chat room collections.
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null || currentUser.email == null) {
      throw Exception('Firebase sign in is required to send messages.');
    }

    if (currentUser.uid == receiverId) {
      throw Exception('You cannot send a chat message to yourself.');
    }

    final chatRoomId = getChatRoomId(currentUser.uid, receiverId);
    final timestamp = Timestamp.now();
    final newMessage = MessageModel(
      senderId: currentUser.uid,
      senderEmail: currentUser.email!,
      receiverId: receiverId,
      message: message.trim(),
      timestamp: timestamp,
    );

    await _chatRoomsCollection.doc(chatRoomId).set({
      'participants': [currentUser.uid, receiverId],
      'lastMessage': message.trim(),
      'lastMessageAt': timestamp,
    }, SetOptions(merge: true));

    await _chatRoomsCollection
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages({
    required String userId,
    required String otherUserId,
  }) {
    final chatRoomId = getChatRoomId(userId, otherUserId);

    return _chatRoomsCollection
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
