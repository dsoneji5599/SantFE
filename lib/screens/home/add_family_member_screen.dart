import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/provider/home_provider.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _natureOfBusinessController =
      TextEditingController();
  final TextEditingController _gacchController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _spouseNameController = TextEditingController();
  final TextEditingController _dateOfMarriageController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  XFile? _pickedImage;
  DateTime? _selectedDob;
  DateTime? _selectedMarriageDate;

  final List<_ChildForm> _children = [
    _ChildForm(
      name: TextEditingController(),
      dob: TextEditingController(),
      gender: 'Female',
    ),
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
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
                    "Add Family Details",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    [
                          AppTextfield(
                            controller: _nameController,
                            label: "Name",
                            hintText: 'Enter your name',
                          ),
                          Text(
                            "Photo",
                            style: AppFonts.outfitBlack.copyWith(fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                                image: _pickedImage != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(_pickedImage!.path),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _pickedImage == null
                                  ? const Center(
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          AppTextfield(
                            controller: _dobController,
                            label: 'Date Of Birth',
                            hintText: 'DD-MM-YYYY',
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDob ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _selectedDob = picked;
                                _dobController.text =
                                    '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                              }
                            },
                          ),
                          AppTextfield(
                            controller: _qualificationController,
                            label: "Qualification",
                            hintText: 'Enter your qualification',
                          ),
                          AppTextfield(
                            controller: _occupationController,
                            label: "Occupation",
                            hintText: 'Enter your occupation',
                          ),
                          AppTextfield(
                            controller: _natureOfBusinessController,
                            label: "Nature of Business",
                            hintText: 'Enter Nature of your business',
                          ),
                          AppTextfield(
                            controller: _gacchController,
                            label: "Gacch",
                            hintText: 'Enter Gacch',
                          ),
                          AppTextfield(
                            controller: _fatherNameController,
                            label: "Father's Name",
                            hintText: 'Enter Father name',
                          ),
                          AppTextfield(
                            controller: _motherNameController,
                            label: "Mother's Name",
                            hintText: 'Enter Mother name',
                          ),
                          AppTextfield(
                            controller: _spouseNameController,
                            label: "Spouse Name",
                            hintText: 'Enter spouse name',
                          ),
                          AppTextfield(
                            controller: _dateOfMarriageController,
                            label: 'Date Of Marriage',
                            hintText: 'DD-MM-YYYY',
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _selectedMarriageDate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _selectedMarriageDate = picked;
                                _dateOfMarriageController.text =
                                    '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                              }
                            },
                          ),

                          // --------- Contact and address ---------
                          AppTextfield(
                            controller: _phoneController,
                            label: "Phone Number",
                            hintText: 'Enter phone number',
                            textInputType: TextInputType.phone,
                          ),
                          AppTextfield(
                            controller: _cityController,
                            label: "City",
                            hintText: 'Enter your city',
                          ),
                          AppTextfield(
                            controller: _districtController,
                            label: "District",
                            hintText: 'Enter your district',
                          ),
                          AppTextfield(
                            controller: _stateController,
                            label: "State",
                            hintText: 'Enter your state',
                          ),
                          AppTextfield(
                            controller: _countryController,
                            label: "Country",
                            hintText: 'Enter your country',
                          ),

                          // --------- Children dynamic form ---------
                          ...List.generate(_children.length, (i) {
                            final child = _children[i];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Children Name",
                                      style: AppFonts.outfitBlack.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "(${i + 1})",
                                      style: AppFonts.outfitBlack.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AppTextfield(
                                  controller: child.name,
                                  hintText: 'Enter your child name',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Select Gender",
                                  style: AppFonts.outfitBlack.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Male',
                                      groupValue: child.gender,
                                      onChanged: (v) => setState(
                                        () => child.gender = v ?? 'Male',
                                      ),
                                    ),
                                    const Text('Male'),
                                    Radio<String>(
                                      value: 'Female',
                                      groupValue: child.gender,
                                      onChanged: (v) => setState(
                                        () => child.gender = v ?? 'Female',
                                      ),
                                    ),
                                    const Text('Female'),
                                  ],
                                ),
                                AppTextfield(
                                  controller: child.dob,
                                  label: 'Date Of Birth',
                                  hintText: 'DD-MM-YYYY',
                                  readOnly: true,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      child.dob.text =
                                          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                                    }
                                  },
                                ),
                                const SizedBox(height: 5),
                              ],
                            );
                          }),

                          // --------- Add Family Member button (above Submit) ---------
                          Center(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _children.add(
                                    _ChildForm(
                                      name: TextEditingController(),
                                      dob: TextEditingController(),
                                      gender: 'Female',
                                    ),
                                  );
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Add Family Member",
                                    style: AppFonts.outfitBlack.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          AppButton(
                            text: "Submit",
                            onTap: () async {
                              if (_nameController.text.isEmpty ||
                                  _dobController.text.isEmpty ||
                                  _qualificationController.text.isEmpty ||
                                  _occupationController.text.isEmpty ||
                                  _natureOfBusinessController.text.isEmpty ||
                                  _gacchController.text.isEmpty ||
                                  _fatherNameController.text.isEmpty ||
                                  _motherNameController.text.isEmpty ||
                                  _spouseNameController.text.isEmpty ||
                                  _dateOfMarriageController.text.isEmpty ||
                                  _phoneController.text.isEmpty ||
                                  _cityController.text.isEmpty ||
                                  _districtController.text.isEmpty ||
                                  _stateController.text.isEmpty ||
                                  _countryController.text.isEmpty ||
                                  _pickedImage == null) {
                                toastMessage(
                                  "Please fill all required fields!",
                                );
                                return;
                              }

                              for (var c in _children) {
                                if (c.name.text.isEmpty || c.dob.text.isEmpty) {
                                  toastMessage(
                                    "Please fill all children details",
                                  );
                                  return;
                                }
                              }

                              final provider = Provider.of<HomeProvider>(
                                context,
                                listen: false,
                              );

                              List<Map<String, dynamic>> childrenData =
                                  _children.map((c) {
                                    return {
                                      "child_name": c.name.text,
                                      "child_gender": c.gender,
                                      "child_dob": c.dob.text,
                                    };
                                  }).toList();

                              Map<String, dynamic> data = {
                                "name": _nameController.text,
                                "dob": _dobController.text,
                                "qualification": _qualificationController.text,
                                "occupation": _occupationController.text,
                                "nature_of_business":
                                    _natureOfBusinessController.text,
                                "gacch": _gacchController.text,
                                "father_name": _fatherNameController.text,
                                "mother_name": _motherNameController.text,
                                "spouse_name": _spouseNameController.text,
                                "date_of_marriage":
                                    _dateOfMarriageController.text,
                                "phone": _phoneController.text,
                                "city": _cityController.text,
                                "district": _districtController.text,
                                "state": _stateController.text,
                                "country": _countryController.text,
                                "children": childrenData,
                              };

                              bool success = await provider.addFamily(
                                data: data,
                              );
                              if (success) Navigator.pop(context);
                            },
                          ),
                        ]
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: w,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildForm {
  _ChildForm({required this.name, required this.dob, required this.gender});
  final TextEditingController name;
  final TextEditingController dob;
  String gender;
}
