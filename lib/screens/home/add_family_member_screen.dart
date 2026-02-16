import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sant_app/models/family_model.dart';
import 'package:sant_app/provider/home_provider.dart';
import 'package:sant_app/provider/util_provider.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/extensions.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_dropdown.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  final bool isDetail;
  final bool isEdit;
  final FamilyModel? family;

  const AddFamilyMemberScreen({
    super.key,
    this.isDetail = false,
    this.isEdit = false,
    this.family,
  });

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  XFile? _pickedImage;
  DateTime? _selectedDob;
  DateTime? _selectedMarriageDate;

  // Store original values for edit comparison
  String? _originalName;
  String? _originalDob;
  String? _originalQualification;
  String? _originalOccupation;
  String? _originalNatureOfBusiness;
  String? _originalGachh;
  String? _originalFatherName;
  String? _originalMotherName;
  String? _originalSpouseName;
  String? _originalDom;
  String? _originalPhone;
  String? _originalCity;
  String? _originalDistrict;
  String? _originalState;
  String? _originalCountry;
  List<Map<String, dynamic>>? _originalChildrenData;

  String? selectedCity;
  String? selectedDistrict;
  String? selectedState;
  String? selectedCountry;

  late UtilProvider utilProvider;

  final List<_ChildForm> _children = [
    _ChildForm(
      name: TextEditingController(),
      dob: TextEditingController(),
      gender: 'Female',
    ),
  ];

  bool get isReadOnly => widget.isDetail == true;

  Future<void> _pickImage() async {
    if (isReadOnly) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  bool _hasChildrenDataChanged(List<Map<String, dynamic>> currentData) {
    if (_originalChildrenData == null) return false;
    if (currentData.length != _originalChildrenData!.length) return true;

    for (int i = 0; i < currentData.length; i++) {
      if (currentData[i]["child_name"] !=
              _originalChildrenData![i]["child_name"] ||
          currentData[i]["child_gender"] !=
              _originalChildrenData![i]["child_gender"] ||
          currentData[i]["child_dob"] !=
              _originalChildrenData![i]["child_dob"]) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    utilProvider = Provider.of<UtilProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await utilProvider.getCountry();
      setState(() {});
    });

    if (widget.family != null) {
      final f = widget.family!;

      _nameController.text = f.name ?? '';
      _originalName = f.name;

      _dobController.text = (f.dob is DateTime)
          ? (f.dob as DateTime).toDDMMYYYYDash()
          : (f.dob?.toString() ?? '');
      _originalDob = _dobController.text;

      _qualificationController.text = f.qualification ?? '';
      _originalQualification = f.qualification;

      _occupationController.text = f.occupation ?? '';
      _originalOccupation = f.occupation;

      _natureOfBusinessController.text = f.natureOfBusiness ?? '';
      _originalNatureOfBusiness = f.natureOfBusiness;

      _gacchController.text = f.gachh ?? '';
      _originalGachh = f.gachh;

      _fatherNameController.text = f.fatherName ?? '';
      _originalFatherName = f.fatherName;

      _motherNameController.text = f.motherName ?? '';
      _originalMotherName = f.motherName;

      _spouseNameController.text = f.spouseName ?? '';
      _originalSpouseName = f.spouseName;

      _dateOfMarriageController.text = (f.dom is DateTime)
          ? (f.dom as DateTime).toDDMMYYYYDash()
          : (f.dom?.toString() ?? '');
      _originalDom = _dateOfMarriageController.text;

      _phoneController.text = f.mobile ?? '';
      _originalPhone = f.mobile;

      selectedCountry = f.country;
      _originalCountry = f.country;

      selectedState = f.state;
      _originalState = f.state;

      selectedCity = f.city;
      _originalCity = f.city;

      selectedDistrict = f.district;
      _originalDistrict = f.district;

      if (f.childrenDetails != null) {
        _children.clear();
        _originalChildrenData = [];
        for (var c in f.childrenDetails!) {
          _children.add(
            _ChildForm(
              name: TextEditingController(text: c["child_name"] ?? ''),
              dob: TextEditingController(text: c["child_dob"] ?? ''),
              gender: c["child_gender"] ?? "Male",
            ),
          );
          _originalChildrenData!.add({
            "child_name": c["child_name"] ?? '',
            "child_gender": c["child_gender"] ?? "Male",
            "child_dob": c["child_dob"] ?? '',
          });
        }
      }
    }
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
                    widget.isDetail == true
                        ? "Family Details"
                        : (widget.isEdit == true
                              ? "Edit Family Member"
                              : "Add Family Details"),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      [
                            AppTextfield(
                              controller: _nameController,
                              label: "Name",
                              hintText: 'Enter your name',
                              enabled: !isReadOnly,
                            ),
                            Text(
                              "Photo",
                              style: AppFonts.outfitBlack.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: isReadOnly ? null : _pickImage,
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
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
                                    ? (widget.family?.profileImage != null &&
                                              widget
                                                  .family!
                                                  .profileImage!
                                                  .isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  widget.family!.profileImage!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                    Icons.person,
                                                    color: Colors.grey.shade400,
                                                    size: 40,
                                                  ),
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.add_photo_alternate,
                                                color: Colors.grey,
                                                size: 40,
                                              ),
                                            ))
                                    : null,
                              ),
                            ),
                            AppTextfield(
                              controller: _dobController,
                              label: 'Date Of Birth',
                              hintText: 'YYYY-MM-DD',
                              readOnly: true,
                              enabled: !isReadOnly,
                              onTap: () async {
                                if (isReadOnly) return;
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDob ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  _selectedDob = picked;
                                  _dobController.text = picked.toDDMMYYYYDash();
                                }
                              },
                            ),
                            AppTextfield(
                              controller: _qualificationController,
                              label: "Qualification",
                              hintText: 'Enter your qualification',
                              enabled: !isReadOnly,
                            ),
                            AppTextfield(
                              controller: _occupationController,
                              label: "Occupation",
                              hintText: 'Enter your occupation',
                              enabled: !isReadOnly,
                            ),
                            AppTextfield(
                              controller: _natureOfBusinessController,
                              label: "Nature of Business",
                              hintText: 'Enter Nature of your business',
                              enabled: !isReadOnly,
                            ),
                            AppTextfield(
                              controller: _gacchController,
                              label: "Gacch",
                              hintText: 'Enter Gacch',
                              enabled: !isReadOnly,
                            ),
                            AppTextfield(
                              controller: _fatherNameController,
                              label: "Father's Name",
                              hintText: 'Enter Father name',
                              enabled: !isReadOnly,
                            ),
                            AppTextfield(
                              controller: _motherNameController,
                              label: "Mother's Name",
                              hintText: 'Enter Mother name',
                              enabled: !isReadOnly,
                            ),
                            AppTextfield(
                              controller: _spouseNameController,
                              label: "Spouse Name",
                              hintText: 'Enter spouse name',
                              enabled: !isReadOnly,
                            ),
                            AppTextfield(
                              controller: _dateOfMarriageController,
                              label: 'Date Of Marriage',
                              hintText: 'DD-MM-YYYY',
                              readOnly: true,
                              enabled: !isReadOnly,
                              onTap: () async {
                                if (isReadOnly) return;
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _selectedMarriageDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  _selectedMarriageDate = picked;
                                  _dateOfMarriageController.text = picked
                                      .toDDMMYYYYDash();
                                }
                              },
                            ),
                            AppTextfield(
                              controller: _phoneController,
                              label: "Phone Number",
                              hintText: 'Enter phone number',
                              textInputType: TextInputType.phone,
                              enabled: !isReadOnly,
                            ),
                            AppDropdown<String>(
                              value: selectedCountry,
                              label: "Country",
                              hintText: 'Select your Country',
                              isRequired: false,
                              enabled: !isReadOnly,
                              items: utilProvider.countryList.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country.countryId,
                                  child: Text(country.country ?? ''),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                if (isReadOnly) return;
                                setState(() {
                                  selectedCountry = newValue;
                                  selectedState = null;
                                  selectedCity = null;
                                  selectedDistrict = null;
                                });
                                if (newValue != null) {
                                  await utilProvider.getState(
                                    countryId: newValue,
                                  );
                                  setState(() {});
                                }
                              },
                            ),
                            AppDropdown<String>(
                              value: selectedState,
                              label: "State",
                              hintText: 'Select your State',
                              isRequired: false,
                              enabled: !isReadOnly,
                              items: utilProvider.stateList.map((state) {
                                return DropdownMenuItem<String>(
                                  value: state.stateId,
                                  child: Text(state.state ?? ''),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                if (isReadOnly) return;
                                setState(() {
                                  selectedState = newValue;
                                  selectedCity = null;
                                  selectedDistrict = null;
                                });
                                if (newValue != null) {
                                  await utilProvider.getCity(stateId: newValue);
                                  setState(() {});
                                }
                              },
                            ),
                            AppDropdown<String>(
                              value: selectedCity,
                              label: "City",
                              hintText: 'Select your City',
                              isRequired: false,
                              enabled: !isReadOnly,
                              items: utilProvider.cityList.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city.cityId,
                                  child: Text(city.city ?? ''),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                if (isReadOnly) return;
                                setState(() {
                                  selectedCity = newValue;
                                  selectedDistrict = null;
                                });
                                if (newValue != null) {
                                  await utilProvider.getDistrict(
                                    cityId: newValue,
                                  );
                                  setState(() {});
                                }
                              },
                            ),
                            AppDropdown<String>(
                              value: selectedDistrict,
                              label: "District",
                              hintText: 'Select your District',
                              isRequired: false,
                              enabled: !isReadOnly,
                              items: utilProvider.districtList.map((district) {
                                return DropdownMenuItem<String>(
                                  value: district.districtId,
                                  child: Text(district.district ?? ''),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (isReadOnly) return;
                                setState(() {
                                  selectedDistrict = newValue;
                                });
                              },
                            ),
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
                                    enabled: !isReadOnly,
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
                                        onChanged: isReadOnly
                                            ? null
                                            : (v) => setState(
                                                () =>
                                                    child.gender = v ?? 'Male',
                                              ),
                                      ),
                                      const Text('Male'),
                                      Radio<String>(
                                        value: 'Female',
                                        groupValue: child.gender,
                                        onChanged: isReadOnly
                                            ? null
                                            : (v) => setState(
                                                () => child.gender =
                                                    v ?? 'Female',
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
                                    enabled: !isReadOnly,
                                    onTap: () async {
                                      if (isReadOnly) return;
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        child.dob.text = picked
                                            .toDDMMYYYYDash();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              );
                            }),
                            if (!isReadOnly)
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
                            if (!isReadOnly)
                              AppButton(
                                text: "Submit",
                                onTap: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    toastMessage(
                                      "Please fill all required fields!",
                                    );
                                    return;
                                  }

                                  // if (_pickedImage == null &&
                                  //     widget.family == null) {
                                  //   toastMessage("Please select an image!");
                                  //   return;
                                  // }

                                  for (var c in _children) {
                                    if (c.name.text.isEmpty ||
                                        c.dob.text.isEmpty) {
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

                                  String formattedDob = "";
                                  if (_selectedDob != null) {
                                    formattedDob =
                                        "${_selectedDob!.year.toString().padLeft(4, '0')}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}";
                                  }

                                  String formattedDom = "";
                                  if (_selectedMarriageDate != null) {
                                    formattedDom =
                                        "${_selectedMarriageDate!.year.toString().padLeft(4, '0')}-${_selectedMarriageDate!.month.toString().padLeft(2, '0')}-${_selectedMarriageDate!.day.toString().padLeft(2, '0')}";
                                  }

                                  String? base64Image;
                                  if (_pickedImage != null) {
                                    final bytes = await File(
                                      _pickedImage!.path,
                                    ).readAsBytes();
                                    base64Image = base64Encode(bytes);
                                  }

                                  Map<String, dynamic> data = {};

                                  if (widget.isEdit == true) {
                                    // Only add fields that have changed
                                    if (_nameController.text !=
                                        (_originalName ?? '')) {
                                      data["name"] = _nameController.text;
                                    }
                                    if (_dobController.text !=
                                        (_originalDob ?? '')) {
                                      data["dob"] = formattedDob;
                                    }
                                    if (_qualificationController.text !=
                                        (_originalQualification ?? '')) {
                                      data["qualification"] =
                                          _qualificationController.text;
                                    }
                                    if (_occupationController.text !=
                                        (_originalOccupation ?? '')) {
                                      data["occupation"] =
                                          _occupationController.text;
                                    }
                                    if (_natureOfBusinessController.text !=
                                        (_originalNatureOfBusiness ?? '')) {
                                      data["nature_of_business"] =
                                          _natureOfBusinessController.text;
                                    }
                                    if (_gacchController.text !=
                                        (_originalGachh ?? '')) {
                                      data["gachh"] = _gacchController.text;
                                    }
                                    if (_fatherNameController.text !=
                                        (_originalFatherName ?? '')) {
                                      data["father_name"] =
                                          _fatherNameController.text;
                                    }
                                    if (_motherNameController.text !=
                                        (_originalMotherName ?? '')) {
                                      data["mother_name"] =
                                          _motherNameController.text;
                                    }
                                    if (_spouseNameController.text !=
                                        (_originalSpouseName ?? '')) {
                                      data["spouse_name"] =
                                          _spouseNameController.text;
                                    }
                                    if (_dateOfMarriageController.text !=
                                        (_originalDom ?? '')) {
                                      data["dom"] = formattedDom;
                                    }
                                    if (_phoneController.text !=
                                        (_originalPhone ?? '')) {
                                      data["mobile"] = _phoneController.text;
                                    }
                                    if (selectedCity != _originalCity) {
                                      data["city"] = selectedCity;
                                    }
                                    if (selectedDistrict != _originalDistrict) {
                                      data["district"] = selectedDistrict;
                                    }
                                    if (selectedState != _originalState) {
                                      data["state"] = selectedState;
                                    }
                                    if (selectedCountry != _originalCountry) {
                                      data["country"] = selectedCountry;
                                    }
                                    if (_hasChildrenDataChanged(childrenData)) {
                                      data["children_details"] = childrenData;
                                    }

                                    if (base64Image != null) {
                                      data["profile_image"] = base64Image;
                                    }
                                  } else {
                                    // For new family members, include all fields
                                    data = {
                                      "name": _nameController.text,
                                      "dob": formattedDob,
                                      "qualification":
                                          _qualificationController.text,
                                      "occupation": _occupationController.text,
                                      "nature_of_business":
                                          _natureOfBusinessController.text,
                                      "gachh": _gacchController.text,
                                      "father_name": _fatherNameController.text,
                                      "mother_name": _motherNameController.text,
                                      "spouse_name": _spouseNameController.text,
                                      "dom": formattedDom,
                                      "mobile": _phoneController.text,
                                      "city": selectedCity,
                                      "district": selectedDistrict,
                                      "state": selectedState,
                                      "country": selectedCountry,
                                      "children_details": childrenData,
                                    };

                                    if (base64Image != null) {
                                      data["profile_image"] = base64Image;
                                    }
                                  }

                                  if (widget.isEdit == true) {
                                    bool success = await provider.editFamily(
                                      data: data,
                                      userFamilyId:
                                          widget.family?.userFamilyId ?? '',
                                    );
                                    if (success) Navigator.pop(context);
                                  } else {
                                    bool success = await provider.addFamily(
                                      data: data,
                                    );
                                    if (success) Navigator.pop(context);
                                  }
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
