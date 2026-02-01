import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/sant_list_model.dart';
import 'package:sant_app/provider/sant_provider.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _fetchGroup() async {
    final snap = await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get();
    return snap.data();
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _fetchMembers(
    List<String> uids,
  ) async {
    if (uids.isEmpty) return [];

    final snap = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .get();

    return snap.docs;
  }

  Future<void> _removeMember(String uid) async {
    await _firestore.collection('groups').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
    setState(() {});
  }

  Future<void> _leaveGroup() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('groups').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([user.uid]),
    });
    Navigator.pop(context);
  }

  Future<void> _deleteGroup() async {
    final ref = _firestore.collection('groups').doc(widget.groupId);
    final msgs = ref.collection('messages');

    Future<void> del() async {
      final s = await msgs.limit(100).get();
      if (s.docs.isEmpty) return;
      final b = _firestore.batch();
      for (var d in s.docs) {
        b.delete(d.reference);
      }
      await b.commit();
      if (s.docs.length == 100) await del();
    }

    await del();
    await ref.delete();
    Navigator.pop(context);
  }

  void _showAddMembersPopup(List<String> existing) {
    final santList = context.read<SantProvider>().santList;
    List<SantListModel> filtered = List.from(santList);
    List<String> temp = [];

    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return StatefulBuilder(
          builder: (context, setDialog) {
            void search(String q) {
              q = q.toLowerCase();
              setDialog(() {
                filtered = santList.where((s) {
                  final n = s.name?.toLowerCase() ?? '';
                  final e = s.email?.toLowerCase() ?? '';
                  final m = s.mobile?.toLowerCase() ?? '';
                  return n.contains(q) || e.contains(q) || m.contains(q);
                }).toList();
              });
            }

            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * .75,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Members",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      onChanged: search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final s = filtered[i];
                          final id = s.firebaseUid ?? s.saintId ?? '';
                          final added = existing.contains(id);
                          final sel = temp.contains(id);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  (s.profileImage ?? "").startsWith("http")
                                  ? NetworkImage(s.profileImage!)
                                  : null,
                            ),
                            title: Text(s.name ?? "Unnamed"),
                            subtitle: Text(
                              s.email?.isNotEmpty == true
                                  ? s.email!
                                  : s.mobile ?? '',
                            ),
                            trailing: added
                                ? const Text("Added")
                                : Checkbox(
                                    value: sel,
                                    onChanged: (v) {
                                      setDialog(() {
                                        if (v == true) {
                                          temp.add(id);
                                        } else {
                                          temp.remove(id);
                                        }
                                      });
                                    },
                                  ),
                            onTap: added
                                ? null
                                : () {
                                    setDialog(() {
                                      if (sel) {
                                        temp.remove(id);
                                      } else {
                                        temp.add(id);
                                      }
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (temp.isNotEmpty) {
                          await _firestore
                              .collection('groups')
                              .doc(widget.groupId)
                              .update({'members': FieldValue.arrayUnion(temp)});
                        }
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text("Add Selected Members"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchGroup(),
      builder: (context, s) {
        if (!s.hasData) {
          return const AppScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final g = s.data!;
        final name = g['name'] ?? "";
        final img = g['imageUrl'] ?? "";
        final adminId = g['adminId'];
        final members = List<String>.from(g['members'] ?? []);
        final uid = _auth.currentUser?.uid;
        final isAdmin = uid == adminId;

        return AppScaffold(
          body: Column(
            children: [
              const SizedBox(height: 60),
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
                        name,
                        style: AppFonts.outfitBlack.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showMenu(
                          context: context,
                          position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
                          items: isAdmin
                              ? const [
                                  PopupMenuItem(
                                    value: "delete",
                                    child: Text("Delete Group"),
                                  ),
                                ]
                              : const [
                                  PopupMenuItem(
                                    value: "leave",
                                    child: Text("Leave Group"),
                                  ),
                                ],
                        ).then((v) async {
                          if (v == "delete") await _deleteGroup();
                          if (v == "leave") await _leaveGroup();
                        });
                      },
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
              CircleAvatar(
                radius: 48,
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty
                    ? Text((name.isNotEmpty ? name[0] : '?').toUpperCase())
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text("Members: ${members.length}"),
              const SizedBox(height: 10),

              Expanded(
                child:
                    FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                      future: _fetchMembers(members),
                      builder: (context, m) {
                        final docs = m.data ?? [];
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (c, i) {
                            final d = docs[i];
                            final data = d.data();
                            final id = d.id;
                            final adm = id == adminId;

                            final profile = (data?['profileImage'] ?? "")
                                .toString();
                            final santList = context
                                .read<SantProvider>()
                                .santList;

                            final email = (data?['email'] ?? "")
                                .toString()
                                .toLowerCase();

                            String phone = (data?['phone'] ?? "").toString();
                            phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                            if (phone.length > 10) {
                              phone = phone.substring(phone.length - 10);
                            }

                            final matchedSant = santList.firstWhere((s) {
                              final santEmail = (s.email ?? "").toLowerCase();

                              String santPhone = (s.mobile ?? "");
                              santPhone = santPhone.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              if (santPhone.length > 10) {
                                santPhone = santPhone.substring(
                                  santPhone.length - 10,
                                );
                              }

                              return (email.isNotEmpty && santEmail == email) ||
                                  (phone.isNotEmpty && santPhone == phone);
                            }, orElse: () => SantListModel());

                            final name = matchedSant.name?.isNotEmpty == true
                                ? matchedSant.name!
                                : "Unnamed";

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundImage: profile.startsWith('http')
                                    ? NetworkImage(profile)
                                    : null,
                                child: !profile.startsWith('http')
                                    ? Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : "?",
                                      )
                                    : null,
                              ),
                              title: Text(name),
                              subtitle: Text(
                                adm
                                    ? "Admin"
                                    : (email.isNotEmpty ? email : phone),
                              ),
                              trailing: isAdmin && !adm
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () async {
                                        final c = await showDialog<bool>(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                            title: const Text('Remove Member'),
                                            content: Text('Remove $name?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(c, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(c, true),
                                                child: const Text('Remove'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (c == true) await _removeMember(id);
                                      },
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 25,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: isAdmin
                          ? ElevatedButton.icon(
                              onPressed: () => _showAddMembersPopup(members),
                              icon: const Icon(Icons.person_add),
                              label: const Text("Add Members"),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
