import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/sant_list_model.dart';
import 'package:sant_app/provider/sant_provider.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'group_detail_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String groupName;
  final String groupId;
  const ChatRoomScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    final user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({'lastSeenBy.${user.uid}': FieldValue.serverTimestamp()});
    }
  }

  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    final santList = context.read<SantProvider>().santList;

    final email = (userDoc.data()?['email'] ?? "").toString().toLowerCase();

    String phone = (userDoc.data()?['phone'] ?? "").toString();
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length > 10) {
      phone = phone.substring(phone.length - 10);
    }

    final matchedSant = santList.firstWhere(
      (s) =>
          s.firebaseUid == user.uid ||
          (email.isNotEmpty && (s.email ?? "").toLowerCase() == email) ||
          (phone.isNotEmpty &&
              (s.mobile ?? "")
                  .replaceAll(RegExp(r'[^0-9]'), '')
                  .endsWith(phone)),
      orElse: () => SantListModel(),
    );

    String senderName = matchedSant.name?.isNotEmpty == true
        ? matchedSant.name!
        : "Unnamed";

    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
          'text': message,
          'senderId': user.uid,
          'senderName': senderName,
          'timestamp': FieldValue.serverTimestamp(),
        });

    await _firestore.collection('groups').doc(widget.groupId).update({
      'lastSeenBy.${user.uid}': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  void _showGroupOptionsDialog() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final groupSnap = await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get();
    if (!groupSnap.exists) return;

    final groupData = groupSnap.data()!;
    final adminUid = groupData['adminId'];
    final isAdmin = adminUid == user.uid;

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(widget.groupName),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupDetailScreen(groupId: widget.groupId),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Group info'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _handleLeavePressed(isAdmin);
              },
              child: ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text(isAdmin ? 'Delete group' : 'Leave group'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLeavePressed(bool isAdmin) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (isAdmin) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete group'),
          content: const Text('Are you sure you want to delete this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm == true) await _deleteGroup();
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave group'),
          content: const Text('Are you sure you want to leave?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      if (confirm == true) await _leaveGroup();
    }
  }

  Future<void> _leaveGroup() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final groupRef = _firestore.collection('groups').doc(widget.groupId);

    await groupRef.update({
      'members': FieldValue.arrayRemove([user.uid]),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _deleteGroup() async {
    final groupRef = _firestore.collection('groups').doc(widget.groupId);
    final messagesRef = groupRef.collection('messages');

    const batchSize = 100;

    Future<void> deleteBatch() async {
      final snap = await messagesRef.limit(batchSize).get();
      if (snap.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length == batchSize) await deleteBatch();
    }

    await deleteBatch();
    await groupRef.delete();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          const SizedBox(height: 60),

          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.groupName,
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: _showGroupOptionsDialog,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet. Say hi!",
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final messageText = msg['text'] ?? '';
                    final senderId = msg['senderId'] ?? '';

                    final santList = context.read<SantProvider>().santList;

                    final matchedSant = santList.firstWhere(
                      (s) => s.firebaseUid == senderId,
                      orElse: () => SantListModel(),
                    );

                    final resolvedName = matchedSant.name?.isNotEmpty == true
                        ? matchedSant.name!
                        : (msg['senderName'] ?? 'Unnamed');

                    final isMe = senderId == _auth.currentUser?.uid;

                    final displayName = isMe ? "You" : resolvedName;

                    final timestamp = msg['timestamp'] as Timestamp?;
                    final timeString = timestamp != null
                        ? TimeOfDay.fromDateTime(
                            timestamp.toDate(),
                          ).format(context)
                        : '';

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isMe
                                ? const Radius.circular(18)
                                : const Radius.circular(4),
                            bottomRight: isMe
                                ? const Radius.circular(4)
                                : const Radius.circular(18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "-$displayName",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messageText,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                timeString,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input area
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 25,
            ).copyWith(top: 5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            textInputAction: TextInputAction.send,
                            decoration: const InputDecoration(
                              hintText: "Type here...",
                              hintStyle: TextStyle(
                                color: Colors.black38,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send, color: Colors.black87),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
