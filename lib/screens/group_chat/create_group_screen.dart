import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/sant_list_model.dart';
import 'package:sant_app/provider/sant_provider.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class CreateGroupScreen extends StatefulWidget {
  final String? groupId;
  final bool isEdit;

  const CreateGroupScreen({super.key, this.groupId, this.isEdit = false});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();

  XFile? _pickedImage;
  bool _isLoading = false;
  bool isLoadingUsers = true;

  List<Map<String, dynamic>> allUsers =
      []; // will hold user docs with 'uid' and 'name'
  List<String> _selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    if (widget.isEdit) _loadGroupData();
    _membersController.text = '';
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupData() async {
    final doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();

    final data = doc.data();
    if (data == null) return;

    _groupNameController.text = data['name'] ?? '';

    final members = List<String>.from(data['members'] ?? []);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    members.remove(uid);

    setState(() {
      _selectedUserIds = members;
      _membersController.text = _getSelectedUserNamesFromSantList(context);
    });
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoadingUsers = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isUser', isEqualTo: false)
          .get();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      setState(() {
        allUsers = snapshot.docs
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
        isLoadingUsers = false;
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

      final groups = FirebaseFirestore.instance.collection('groups');

      if (widget.isEdit && widget.groupId != null) {
        await groups.doc(widget.groupId).update({
          'name': _groupNameController.text.trim(),
          if (imageUrl != null) 'imageUrl': imageUrl,
          'members': [..._selectedUserIds, currentUser.uid],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await groups.add({
          'name': _groupNameController.text.trim(),
          'imageUrl': imageUrl ?? '',
          'adminId': currentUser.uid,
          'members': [..._selectedUserIds, currentUser.uid],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      toastMessage('Group created successfully');

      Navigator.pop(context, true);
    } catch (e) {
      log(e.toString(), name: "Creating Group");
      toastMessage('Failed to create group, try again later');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSelectMembersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final santList = context.read<SantProvider>().santList;
        List<SantListModel> filteredList = List.from(santList);
        List<String> tempSelected = List.from(_selectedUserIds);
        final TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Filter Sants by name, email, or mobile
            void filterSants(String query) {
              query = query.toLowerCase();
              setStateDialog(() {
                filteredList = santList.where((sant) {
                  final name = sant.name?.toLowerCase() ?? '';
                  final email = sant.email?.toLowerCase() ?? '';
                  final mobile = sant.mobile?.toLowerCase() ?? '';
                  return name.contains(query) ||
                      email.contains(query) ||
                      mobile.contains(query);
                }).toList();
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Group member',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email or mobile...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      onChanged: filterSants,
                    ),
                    const SizedBox(height: 16),

                    // Contacts header
                    const Text(
                      'Your Contacts',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // List of sants
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text('No Sant found'))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final sant = filteredList[index];
                                final isSelected = tempSelected.contains(
                                  sant.firebaseUid ?? sant.saintId ?? '',
                                );

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: (() {
                                    final img =
                                        sant.profileImage?.toString().trim() ??
                                        '';

                                    final isValidUrl =
                                        img.startsWith('http://') ||
                                        img.startsWith('https://');

                                    if (isValidUrl) {
                                      return CircleAvatar(
                                        backgroundImage: NetworkImage(img),
                                        radius: 24,
                                      );
                                    } else {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade200,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 26,
                                          color: Colors.grey,
                                        ),
                                      );
                                    }
                                  })(),

                                  title: Text(
                                    sant.name ?? 'Unnamed',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    sant.email?.isNotEmpty == true
                                        ? sant.email!
                                        : sant.mobile ?? '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    activeColor: AppColors.appOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (checked) {
                                      setStateDialog(() {
                                        final id =
                                            sant.firebaseUid ??
                                            sant.saintId ??
                                            '';
                                        if (checked == true) {
                                          tempSelected.add(id);
                                        } else {
                                          tempSelected.remove(id);
                                        }
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setStateDialog(() {
                                      final id =
                                          sant.firebaseUid ??
                                          sant.saintId ??
                                          '';
                                      if (isSelected) {
                                        tempSelected.remove(id);
                                      } else {
                                        tempSelected.add(id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: count and text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${tempSelected.length} member${tempSelected.length == 1 ? '' : 's'} selected',
                                  style: TextStyle(
                                    color: AppColors.appOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Do you want to add selected members into your group?",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Confirm button
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedUserIds = tempSelected;
                                _membersController.text =
                                    _getSelectedUserNamesFromSantList(context);
                              });
                              Navigator.pop(context);
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.appOrange,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  String _getSelectedUserNamesFromSantList(BuildContext context) {
    final santList = context.read<SantProvider>().santList;
    final selectedNames = santList
        .where(
          (sant) =>
              _selectedUserIds.contains(sant.firebaseUid ?? sant.saintId ?? ''),
        )
        .map((sant) => sant.name ?? 'Unnamed')
        .toList();
    return selectedNames.isNotEmpty ? selectedNames.join(', ') : 'Unnamed';
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
                    onTap: () => _showSelectMembersDialog(context),
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AppButton(
                          text: widget.isEdit ? "Update" : "Create",
                          onTap: _createGroup,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
