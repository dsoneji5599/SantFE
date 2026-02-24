import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:sant_app/provider/profile_provider.dart';
import 'package:sant_app/provider/util_provider.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_dropdown.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class UpdateUserProfileScreen extends StatefulWidget {
  final bool isUser;
  const UpdateUserProfileScreen({super.key, required this.isUser});

  @override
  State<UpdateUserProfileScreen> createState() =>
      _UpdateUserProfileScreenState();
}

class _UpdateUserProfileScreenState extends State<UpdateUserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _salutationController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _sampradayController = TextEditingController();
  final TextEditingController _upadhiController = TextEditingController();
  final TextEditingController _sanghController = TextEditingController();
  final TextEditingController _dikshaPlaceController = TextEditingController();
  final TextEditingController _dikshaDateController = TextEditingController();
  final TextEditingController _tapasyaDetailController =
      TextEditingController();
  final TextEditingController _knowledgeDetailController =
      TextEditingController();
  final TextEditingController _viharDetailController = TextEditingController();

  String? selectedCity;
  String? selectedDistrict;
  String? selectedState;
  String? selectedCountry;
  String? selectedSamaj;
  String? selectedGender;

  late UtilProvider utilProvider;
  late UserProfileProvider userProfileProvider;

  XFile? _pickedImage;

  DateTime? _selectedDob;
  DateTime? _selectedDikshaDate;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    utilProvider = Provider.of<UtilProvider>(context, listen: false);
    userProfileProvider = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isUser) {
        await userProfileProvider.getProfile();
        final profile = userProfileProvider.userProfileModel;

        _nameController.text = profile?.name ?? '';
        _emailController.text = profile?.email ?? '';
        _phoneController.text = profile?.mobile ?? '';
        if (profile?.dob != null) {
          _selectedDob = DateTime.tryParse(profile!.dob!.toString());
          if (_selectedDob != null) {
            _dobController.text =
                '${_selectedDob!.day.toString().padLeft(2, '0')}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.year}';
          }
        }

        selectedCountry = profile?.country;
        selectedState = profile?.state;
        selectedCity = profile?.city;
        selectedDistrict = profile?.district;
        selectedSamaj = profile?.samaj;
      } else {
        await userProfileProvider.getProfile();
        final santProfile = userProfileProvider.santProfileModel;

        _nameController.text = santProfile?.name ?? '';
        _emailController.text = santProfile?.email ?? '';
        _phoneController.text = santProfile?.mobile ?? '';
        _salutationController.text = santProfile?.salutation ?? '';
        _genderController.text = santProfile?.gender ?? '';
        _sampradayController.text = santProfile?.sampraday ?? '';
        _upadhiController.text = santProfile?.upadhi ?? '';
        _sanghController.text = santProfile?.sangh ?? '';
        _dikshaPlaceController.text = santProfile?.dikshaPlace ?? '';
        _tapasyaDetailController.text = santProfile?.tapasyaDetails ?? '';
        _knowledgeDetailController.text = santProfile?.knowledgeDetails ?? '';
        _viharDetailController.text = santProfile?.viharDetails ?? '';

        if (santProfile?.dob != null) {
          _selectedDob = DateTime.tryParse(santProfile!.dob!.toString());
          if (_selectedDob != null) {
            _dobController.text =
                '${_selectedDob!.day.toString().padLeft(2, '0')}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.year}';
          }
        }

        if (santProfile?.dikshaDate != null) {
          _selectedDikshaDate = DateTime.tryParse(
            santProfile!.dikshaDate!.toString(),
          );
          if (_selectedDikshaDate != null) {
            _dikshaDateController.text =
                '${_selectedDikshaDate!.day.toString().padLeft(2, '0')}-${_selectedDikshaDate!.month.toString().padLeft(2, '0')}-${_selectedDikshaDate!.year}';
          }
        }

        selectedCountry = santProfile?.country;
        selectedState = santProfile?.state;
        selectedCity = santProfile?.city;
        selectedDistrict = santProfile?.district;
        selectedSamaj = santProfile?.samaj;
        selectedGender = santProfile?.gender;
      }

      await utilProvider.getCountry();
      await utilProvider.getSamaj();

      if (selectedCountry != null) {
        await utilProvider.getState(countryId: selectedCountry!);
      }
      if (selectedState != null) {
        await utilProvider.getCity(stateId: selectedState!);
      }
      if (selectedCity != null) {
        await utilProvider.getDistrict(cityId: selectedCity!);
      }
      setState(() {});

      _validateDropdownValues();

      setState(() {});
    });
  }

  void _validateDropdownValues() {
    final countryIds = utilProvider.countryList
        .where((c) => c.countryId != null)
        .map((c) => c.countryId)
        .toList();

    if (selectedCountry != null && !countryIds.contains(selectedCountry)) {
      selectedCountry = null;
    }

    final stateIds = utilProvider.stateList
        .where((s) => s.stateId != null)
        .map((s) => s.stateId)
        .toList();

    if (selectedState != null && !stateIds.contains(selectedState)) {
      selectedState = null;
    }

    final cityIds = utilProvider.cityList
        .where((c) => c.cityId != null)
        .map((c) => c.cityId)
        .toList();

    if (selectedCity != null && !cityIds.contains(selectedCity)) {
      selectedCity = null;
    }

    final districtIds = utilProvider.districtList
        .where((d) => d.districtId != null)
        .map((d) => d.districtId)
        .toList();

    if (selectedDistrict != null && !districtIds.contains(selectedDistrict)) {
      selectedDistrict = null;
    }

    // Validate samaj selection
    final samajIds = utilProvider.samajList
        .where((samaj) => samaj.samajId != null)
        .map((samaj) => samaj.samajId)
        .toList();
    if (selectedSamaj != null && !samajIds.contains(selectedSamaj)) {
      selectedSamaj = null;
    }

    // Validate gender selection for sant users
    if (!widget.isUser) {
      final validGenders = ['Male', 'Female', 'Other'];
      if (selectedGender != null && !validGenders.contains(selectedGender)) {
        selectedGender = null;
        _genderController.text = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),

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
                    "Update Profile",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 20),

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

            Container(
              margin: EdgeInsets.symmetric(vertical: 22, horizontal: 34),
              padding: EdgeInsets.all(24).copyWith(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
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
                    controller: _nameController,
                    label: "Name",
                    hintText: 'Enter your name',
                  ),

                  AppTextfield(
                    controller: _phoneController,
                    label: "Phone Number",
                    hintText: 'Enter your Phone Number',
                    textInputType: TextInputType.phone,
                    maxLength: 10,
                    enabled: false,
                  ),

                  AppTextfield(
                    controller: _emailController,
                    label: "Email",
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                    enabled: false,
                  ),

                  AppTextfield(
                    controller: _dobController,
                    label: 'Date Of Birth',
                    hintText: 'DD-MM-YYYY',
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
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

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _salutationController,
                      label: "Salutation",
                      hintText: 'Enter your Salutation',
                    ),

                  if (widget.isUser)
                    AppDropdown<String>(
                      value: selectedCountry,
                      label: "Country",
                      hintText: 'Select your Country',
                      isRequired: false,
                      items: utilProvider.countryList.map((country) {
                        return DropdownMenuItem<String>(
                          value: country.countryId,
                          child: Text(country.country ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        setState(() {
                          selectedCountry = newValue;
                          selectedState = null;
                          selectedCity = null;
                          selectedDistrict = null;
                        });
                        if (newValue != null) {
                          await utilProvider.getState(countryId: newValue);
                          setState(() {});
                        }
                      },
                    ),

                  if (widget.isUser)
                    AppDropdown<String>(
                      value: selectedState,
                      label: "State",
                      hintText: 'Select your State',
                      isRequired: false,
                      items: utilProvider.stateList.map((state) {
                        return DropdownMenuItem<String>(
                          value: state.stateId,
                          child: Text(state.state ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
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

                  if (widget.isUser)
                    AppDropdown<String>(
                      value: selectedCity,
                      label: "City",
                      hintText: 'Select your City',
                      isRequired: false,
                      items: utilProvider.cityList.map((city) {
                        return DropdownMenuItem<String>(
                          value: city.cityId,
                          child: Text(city.city ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        setState(() {
                          selectedCity = newValue;
                          selectedDistrict = null;
                        });
                        if (newValue != null) {
                          await utilProvider.getDistrict(cityId: newValue);
                          setState(() {});
                        }
                      },
                    ),

                  if (widget.isUser)
                    AppDropdown<String>(
                      value: selectedDistrict,
                      label: "District",
                      hintText: 'Select your District',
                      isRequired: false,
                      items: utilProvider.districtList.map((district) {
                        return DropdownMenuItem<String>(
                          value: district.districtId,
                          child: Text(district.district ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDistrict = newValue;
                        });
                      },
                    ),

                  AppDropdown<String>(
                    value:
                        utilProvider.samajList
                            .where((samaj) => samaj.samajId != null)
                            .map((samaj) => samaj.samajId)
                            .contains(selectedSamaj)
                        ? selectedSamaj
                        : null,
                    label: "Samaj",
                    hintText: 'Select your Samaj',
                    isRequired: false,
                    items: utilProvider.samajList
                        .where((samaj) => samaj.samajId != null)
                        .map(
                          (samaj) => DropdownMenuItem<String>(
                            value: samaj.samajId,
                            child: Text(samaj.samajName ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSamaj = newValue;
                      });
                    },
                  ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _sampradayController,
                      label: "Sampraday",
                      hintText: 'Enter your Sampraday',
                    ),

                  if (!widget.isUser)
                    AppDropdown<String>(
                      value:
                          ['Male', 'Female', 'Other'].contains(selectedGender)
                          ? selectedGender
                          : null,
                      label: "Gender",
                      hintText: 'Select your Gender',
                      isRequired: false,
                      items: ['Male', 'Female', 'Other']
                          .map(
                            (gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue;
                          _genderController.text = newValue ?? '';
                        });
                      },
                    ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _upadhiController,
                      label: "Upadhi",
                      hintText: 'Enter your Upadhi',
                    ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _sanghController,
                      label: "Sangh",
                      hintText: 'Enter your Sangh',
                    ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _dikshaPlaceController,
                      label: "Diksha Place",
                      hintText: 'Enter your Diksha Place',
                    ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _dikshaDateController,
                      label: 'Diksha Date',
                      hintText: 'DD-MM-YYYY',
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDikshaDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _selectedDikshaDate = picked;
                          _dikshaDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                        }
                      },
                    ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _tapasyaDetailController,
                      label: "Tapasya Details",
                      hintText: 'Enter your Tapasya Details',
                      maxLines: 3,
                    ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _knowledgeDetailController,
                      label: "Knowledge Details",
                      hintText: 'Enter your Knowledge Details',
                      maxLines: 3,
                    ),

                  if (!widget.isUser)
                    AppTextfield(
                      controller: _viharDetailController,
                      label: "Vihar Details",
                      hintText: 'Enter your Vihar Details',
                      maxLines: 3,
                    ),

                  SizedBox(),

                  Consumer2<UserProfileProvider, UserProfileProvider>(
                    builder: (context, userProvider, santProvider, child) {
                      return AppButton(
                        text: "Update",
                        onTap: () async {
                          String formattedDob = "";
                          if (_selectedDob != null) {
                            formattedDob =
                                '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}';
                          }

                          String formattedDikshaDate = "";
                          if (_selectedDikshaDate != null) {
                            formattedDikshaDate =
                                '${_selectedDikshaDate!.year}-${_selectedDikshaDate!.month.toString().padLeft(2, '0')}-${_selectedDikshaDate!.day.toString().padLeft(2, '0')}';
                          }

                          String? base64Image;
                          if (_pickedImage != null) {
                            final bytes = await File(
                              _pickedImage!.path,
                            ).readAsBytes();
                            base64Image = base64Encode(bytes);
                          }

                          if (widget.isUser) {
                            Map<String, dynamic> data = {
                              "mobile": _phoneController.text,
                              "email": _emailController.text,
                              "name": _nameController.text,
                              "dob": formattedDob,
                              "samaj": selectedSamaj,
                              "district": selectedDistrict,
                              "city": selectedCity,
                              "state": selectedState,
                              "country": selectedCountry,
                              if (base64Image != null)
                                "profile_image": base64Image,
                            };

                            bool updateSuccess = await userProvider
                                .updateProfileProvider(data: data);
                            if (updateSuccess) {
                              userProvider.getProfile();
                              Navigator.pop(context);
                            }
                          } else {
                            Map<String, dynamic> santData = {
                              "mobile": _phoneController.text,
                              "email": _emailController.text,
                              "name": _nameController.text,
                              "dob": formattedDob,
                              "samaj": selectedSamaj,
                              "district": selectedDistrict,
                              "city": selectedCity,
                              "state": selectedState,
                              "country": selectedCountry,
                              "salutation": _salutationController.text,
                              "gender": _genderController.text,
                              "sampraday": _sampradayController.text,
                              "upadhi": _upadhiController.text,
                              "sangh": _sanghController.text,
                              "diksha_place": _dikshaPlaceController.text,
                              "diksha_date": formattedDikshaDate,
                              "tapasya_details": _tapasyaDetailController.text,
                              "knowledge_details":
                                  _knowledgeDetailController.text,
                              "vihar_details": _viharDetailController.text,
                              if (base64Image != null)
                                "profile_image": base64Image,
                            };

                            bool updateSuccess = await santProvider
                                .updateSantProfileProvider(data: santData);
                            if (updateSuccess) {
                              santProvider.getSantProfile();
                              Navigator.pop(context);
                            }
                          }
                        },
                      );
                    },
                  ),
                ].map((e) => Padding(padding: EdgeInsets.only(bottom: 20), child: e)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salutationController.dispose();
    _genderController.dispose();
    _sampradayController.dispose();
    _upadhiController.dispose();
    _sanghController.dispose();
    _dikshaPlaceController.dispose();
    _dikshaDateController.dispose();
    _tapasyaDetailController.dispose();
    _knowledgeDetailController.dispose();
    _viharDetailController.dispose();
    super.dispose();
  }
}
