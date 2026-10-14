import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;
  final String receiverName;

  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        receiverId: widget.receiverId,
        message: message,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Send failed: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName),
            Text(
              widget.receiverEmail,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('Firebase sign in is required.'))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _chatService.getMessages(
                      userId: currentUser.uid,
                      otherUserId: widget.receiverId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Unable to load messages: ${snapshot.error}',
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      _scrollToBottom();

                      if (docs.isEmpty) {
                        return const Center(child: Text('Start the chat.'));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(14.r),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final message = MessageModel.fromMap(
                            docs[index].data(),
                          );
                          final isMine = message.senderId == currentUser.uid;

                          return _AnimatedMessageBubble(
                            key: ValueKey(docs[index].id),
                            message: message,
                            isMine: isMine,
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_isSending)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      'sending...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                _MessageComposer(
                  controller: _messageController,
                  isSending: _isSending,
                  onSend: _sendMessage,
                ),
              ],
            ),
    );
  }
}

class _AnimatedMessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;

  const _AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    // Enhancement 3: Fade and slide message transitions with distinct bubbles.
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 240),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(isMine ? 18 * (1 - value) : -18 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.74.sw),
          margin: EdgeInsets.symmetric(vertical: 5.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isMine ? const Color(0xFF3F51A3) : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
              bottomRight: Radius.circular(isMine ? 4.r : 16.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.message,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black87,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp.toDate()),
                    style: TextStyle(
                      color: isMine ? Colors.white70 : Colors.black54,
                      fontSize: 10.sp,
                    ),
                  ),
                  if (isMine) ...[
                    SizedBox(width: 4.w),
                    Icon(Icons.done_all, color: Colors.white70, size: 14.sp),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Message',
                ),
                onSubmitted: (_) => isSending ? null : onSend(),
              ),
            ),
            SizedBox(width: 8.w),
            IconButton.filled(
              onPressed: isSending ? null : onSend,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
