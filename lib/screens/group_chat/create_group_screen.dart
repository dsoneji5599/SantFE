import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();

  XFile? _pickedImage;
  bool _isLoading = false;
  bool _isLoadingUsers = true;

  List<Map<String, dynamic>> _allUsers =
      []; // will hold user docs with 'uid' and 'name'
  List<String> _selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _membersController.text = '';
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isUser', isEqualTo: false)
          .get();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      setState(() {
        _allUsers = snapshot.docs
            .where((doc) => doc.id != currentUserId)
            .map(
              (doc) => {
                'uid': doc.id,
                'name': (doc.data())['name'] ?? 'Unnamed',
              },
            )
            .toList();
      });
    } catch (e) {
      log('Error fetching users: $e');
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      toastMessage('Please enter a group name');
      return;
    }

    if (_selectedUserIds.isEmpty) {
      toastMessage('Please select at least one member');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      String? imageUrl;

      if (_pickedImage != null) {
        final imageFile = File(_pickedImage!.path);

        if (!imageFile.existsSync()) {
          toastMessage("Image file not found");
          setState(() => _isLoading = false);
          return;
        }

        try {
          final ref = FirebaseStorage.instance.ref().child(
            'group_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          final uploadTask = await ref.putFile(imageFile);

          if (uploadTask.state == TaskState.success) {
            imageUrl = await ref.getDownloadURL();
          } else {
            toastMessage("Image upload failed. Please try again.");
            setState(() => _isLoading = false);
            return;
          }
        } catch (e) {
          log("Image upload error: $e");
          toastMessage("Failed to upload image");
          setState(() => _isLoading = false);
          return;
        }
      }

      final groupData = {
        'name': _groupNameController.text.trim(),
        'imageUrl': imageUrl ?? '',
        'adminId': currentUser.uid,
        'members': [..._selectedUserIds, currentUser.uid],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('groups').add(groupData);

      toastMessage('Group created successfully');

      Navigator.pop(context);
    } catch (e) {
      log(e.toString(), name: "Creating Group");
      toastMessage('Failed to create group, try again later');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSelectMembersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Use temporary copy to allow canceling changes
        var tempSelected = List<String>.from(_selectedUserIds);

        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Select Group Members'),
            content: _allUsers.isEmpty
                ? (_isLoadingUsers
                      ? const SizedBox(
                          height: 100,
                          width: double.maxFinite,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox(
                          height: 100,
                          width: double.maxFinite,
                          child: Center(child: Text('No sant found')),
                        ))
                : SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _allUsers.map((user) {
                          final isSelected = tempSelected.contains(user['uid']);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(user['name']),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (checked) {
                              setStateDialog(() {
                                if (checked == true) {
                                  tempSelected.add(user['uid']);
                                } else {
                                  tempSelected.remove(user['uid']);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedUserIds = tempSelected;
                    _membersController.text = _getSelectedUserNames();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Select'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSelectedUserNames() {
    final names = _allUsers
        .where((user) => _selectedUserIds.contains(user['uid']))
        .map((user) {
          final name = user['name']?.trim() ?? '';
          return name.isEmpty ? 'Unnamed' : name;
        })
        .toList();
    if (names.isEmpty) return 'Unnamed';
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
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
                    "Create Group",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Group Image Selection
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(File(_pickedImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedImage == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE67E22),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Group Details & Members
            Container(
              margin: const EdgeInsets.symmetric(vertical: 22, horizontal: 34),
              padding: const EdgeInsets.all(24).copyWith(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextfield(
                    controller: _groupNameController,
                    label: "Group Name",
                    hintText: 'Enter group name',
                  ),
                  const SizedBox(height: 20),
                  AppTextfield(
                    controller: _membersController,
                    label: "Group Members",
                    hintText: 'Select group members',
                    readOnly: true,
                    onTap: _showSelectMembersDialog,
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AppButton(text: "Create", onTap: _createGroup),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
