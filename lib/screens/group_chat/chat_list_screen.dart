import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sant_app/screens/group_chat/chat_room_screen.dart';
import 'package:sant_app/screens/group_chat/create_group_screen.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late final Stream<QuerySnapshot> _groupsStream;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _groupsStream = FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _groupsStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      fab: FloatingActionButton(
        backgroundColor: AppColors.appOrange,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
        onPressed: () => navigatorPush(context, const CreateGroupScreen()),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),

          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Text(
                  "Chat",
                  style: AppFonts.outfitBlack.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 35),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _groupsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading groups'));
                }

                final groups = snapshot.data?.docs ?? [];

                if (groups.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "No groups Found, Cerate one!",
                            textAlign: TextAlign.center,
                            style: AppFonts.outfitBlack.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // LIST OF GROUPS DISPLAY
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final groupData =
                        groups[index].data()! as Map<String, dynamic>;
                    final groupId = groups[index].id;
                    final groupName = groupData['name'] ?? 'Unnamed Group';
                    final imageUrl = groupData['imageUrl'] as String? ?? '';
                    final Timestamp? createdAtTimestamp =
                        groupData['createdAt'] as Timestamp?;
                    final DateTime createdAt =
                        createdAtTimestamp?.toDate() ?? DateTime.now();

                    return GroupCard(
                      groupId: groupId,
                      groupName: groupName,
                      imageUrl: imageUrl,
                      lastUpdated: createdAt,
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

class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String imageUrl;
  final DateTime lastUpdated;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.imageUrl,
    required this.lastUpdated,
  });

  String get formattedTime {
    final minute = lastUpdated.minute.toString().padLeft(2, '0');
    final ampm = lastUpdated.hour >= 12 ? 'PM' : 'AM';
    final hour12 = lastUpdated.hour > 12
        ? lastUpdated.hour - 12
        : (lastUpdated.hour == 0 ? 12 : lastUpdated.hour);
    return '$hour12:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorPush(
          context,
          ChatRoomScreen(groupId: groupId, groupName: groupName),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey.shade300,
                                );
                              },
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey.shade300,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: AppFonts.outfitBlack.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .snapshots(),
                          builder: (context, groupSnap) {
                            final g = groupSnap.data?.data();

                            final lastSeen =
                                g?['lastSeenBy']?[FirebaseAuth
                                    .instance
                                    .currentUser!
                                    .uid];
                            Timestamp? lastMsgTs;

                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('groups')
                                  .doc(groupId)
                                  .collection('messages')
                                  .orderBy('timestamp', descending: true)
                                  .limit(1)
                                  .snapshots(),
                              builder: (context, snap) {
                                String lastMsg = "";
                                bool hasUnread = false;

                                if (snap.hasData &&
                                    snap.data!.docs.isNotEmpty) {
                                  final d = snap.data!.docs.first.data();
                                  lastMsg = d['text'] ?? "";
                                  lastMsgTs = d['timestamp'];

                                  if (lastMsgTs != null) {
                                    hasUnread =
                                        lastSeen == null ||
                                        lastSeen.toDate().isBefore(
                                          lastMsgTs!.toDate(),
                                        );
                                  }
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMsg.isNotEmpty
                                            ? lastMsg
                                            : "Group chat",
                                        style: AppFonts.outfitBlack.copyWith(
                                          fontSize: 16,
                                          color: AppColors.appGrey.withValues(
                                            alpha: hasUnread ? 1 : 0.5,
                                          ),
                                          fontWeight: hasUnread
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (hasUnread)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppColors.appOrange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 35),
              child: Text(
                formattedTime,
                style: AppFonts.outfitBlack.copyWith(
                  fontSize: 12,
                  color: AppColors.appGrey.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
