import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/provider/home_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_dropdown.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class AddTempleScreen extends StatefulWidget {
  final bool? isDetail;
  final String? imagePath;
  final String? templeName;
  final String? templeType;
  final String? description;

  const AddTempleScreen({
    super.key,
    this.isDetail,
    this.imagePath,
    this.templeName,
    this.templeType,
    this.description,
  });

  @override
  State<AddTempleScreen> createState() => _AddTempleScreenState();
}

class _AddTempleScreenState extends State<AddTempleScreen> {
  final TextEditingController _templeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? selectedTempleType;
  XFile? _pickedImage;
  ImageProvider? initialImage;

  late HomeProvider provider;

  // Temple type options
  final List<String> templeTypes = [
    'Jain',
    'Hindu',
    'Buddhist',
    'Sikh',
    'Other',
  ];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void initState() {
    super.initState();
    _templeNameController.text = widget.templeName ?? '';
    _descriptionController.text = widget.description ?? '';
    if (templeTypes.contains(widget.templeType)) {
      selectedTempleType = widget.templeType;
    } else {
      selectedTempleType = null;
    }

    if (widget.imagePath != null) {
      initialImage = CachedNetworkImageProvider(widget.imagePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),

            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Text(
                    widget.isDetail == true ? "Temple Details" : "Add Temple",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Temple Image Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Temple Image",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 35),
                  GestureDetector(
                    onTap: widget.isDetail == true ? null : _pickImage,
                    child: Center(
                      child: Stack(
                        children: [
                          Transform.rotate(
                            angle: -math.pi / -20,
                            child: Container(
                              width: 170,
                              height: 115,
                              decoration: BoxDecoration(
                                color: Color(0xFF808080),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 170,
                            height: 115,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _pickedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_pickedImage!.path),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : (widget.imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.imagePath!,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey.shade600,
                                                  size: 30,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.add,
                                          color: Colors.grey.shade600,
                                          size: 30,
                                        )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Form Container
            Padding(
              padding: EdgeInsets.all(43).copyWith(top: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      [
                            // Temple Name Field
                            AppTextfield(
                              controller: _templeNameController,
                              label: "Temple Name",
                              hintText: 'Enter temple name..',
                              enabled: widget.isDetail == true ? false : true,
                            ),

                            // Temple Type Dropdown
                            AppDropdown<String>(
                              value: selectedTempleType,
                              label: "Temple Type",
                              hintText: 'Select temple type',
                              isRequired: true,
                              enabled: widget.isDetail == true ? false : true,
                              items: templeTypes
                                  .map(
                                    (type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedTempleType = newValue;
                                });
                              },
                            ),

                            // Description Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description",
                                  style: AppFonts.outfitBlack.copyWith(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextFormField(
                                    enabled: widget.isDetail == true
                                        ? false
                                        : true,
                                    controller: _descriptionController,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Write something about temple ...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(16),
                                    ),
                                    style: AppFonts.outfitBlack.copyWith(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter description';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            // Submit Button
                            if (widget.isDetail == false)
                              AppButton(
                                text: "Submit",
                                onTap: () async {
                                  if (_pickedImage == null) {
                                    showToast('Please select an image');
                                    return;
                                  }

                                  if (_templeNameController.text
                                      .trim()
                                      .isEmpty) {
                                    showToast('Please enter temple name');
                                    return;
                                  }

                                  if (selectedTempleType == null ||
                                      selectedTempleType!.isEmpty) {
                                    showToast('Please select temple type');
                                    return;
                                  }

                                  if (_descriptionController.text
                                      .trim()
                                      .isEmpty) {
                                    showToast('Please enter description');
                                    return;
                                  }

                                  String? base64Image;
                                  if (_pickedImage != null) {
                                    final bytes = await File(
                                      _pickedImage!.path,
                                    ).readAsBytes();
                                    base64Image = base64Encode(bytes);
                                  }

                                  Map<String, dynamic> data = {
                                    "name": _templeNameController.text.trim(),
                                    "type": selectedTempleType,
                                    "description": _descriptionController.text
                                        .trim(),
                                    "image_path": base64Image,
                                  };

                                  bool success = await context
                                      .read<HomeProvider>()
                                      .addTemple(data: data);

                                  if (success) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                          ]
                          .map(
                            (e) => Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: e,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _templeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
