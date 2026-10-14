import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: currentUser == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Please sign in with Firebase to use Firestore chat.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                // Enhancement 2: Search users by name or email.
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search by name or email',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _query = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _chatService.getRegisteredUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Unable to load users: ${snapshot.error}',
                          ),
                        );
                      }

                      final users = (snapshot.data ?? []).where((user) {
                        final name = (user['name'] ?? '')
                            .toString()
                            .toLowerCase();
                        final email = (user['email'] ?? '')
                            .toString()
                            .toLowerCase();
                        return _query.isEmpty ||
                            name.contains(_query) ||
                            email.contains(_query);
                      }).toList();

                      if (users.isEmpty) {
                        return const Center(child: Text('No users found.'));
                      }

                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final name = (user['name'] ?? '').toString();
                          final email = (user['email'] ?? '').toString();

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber.shade200,
                              child: Text(
                                (name.isNotEmpty ? name : email)
                                    .substring(0, 1)
                                    .toUpperCase(),
                              ),
                            ),
                            title: CustomText(
                              text: name.isEmpty ? email : name,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            subtitle: Text(email),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    receiverId: user['uid'] ?? '',
                                    receiverEmail: email,
                                    receiverName: name.isEmpty ? email : name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
