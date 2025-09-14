import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:sant_app/app.dart';
import 'package:sant_app/provider/auth_provider.dart';
import 'package:sant_app/provider/util_provider.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/utils/my_shareprefernce.dart';
import 'package:sant_app/utils/toast_bar.dart';
import 'package:sant_app/widgets/app_button.dart';
import 'package:sant_app/widgets/app_dropdown.dart';
import 'package:sant_app/widgets/app_navigator_animation.dart';
import 'package:sant_app/widgets/app_scaffold.dart';
import 'package:sant_app/widgets/app_textfield.dart';

class RegisterUserScreen extends StatefulWidget {
  final bool isUser;
  final String firebaseUid;
  final String? phoneNumber;
  final String? email;
  final bool isFromPhone;
  const RegisterUserScreen({
    super.key,
    required this.firebaseUid,
    required this.isFromPhone,
    this.phoneNumber,
    this.email,
    required this.isUser,
  });

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
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

  XFile? _pickedImage;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _emailController.text = widget.email ?? "";
      _phoneController.text = widget.phoneNumber ?? "";

      await utilProvider.getCountry();
      await utilProvider.getSamaj();
      setState(() {});
    });
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
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                  Text(
                    "Update Profile",
                    style: AppFonts.outfitBlack.copyWith(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile Image Section
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
                  // Name Field
                  AppTextfield(
                    controller: _nameController,
                    label: "Name",
                    hintText: 'Enter your name',
                  ),

                  if (!widget.isFromPhone)
                    // Phone Field
                    AppTextfield(
                      controller: _phoneController,
                      label: "Phone Number",
                      hintText: 'Enter your Phone Number',
                      textInputType: TextInputType.phone,
                      maxLength: 10,
                      enabled: !widget.isFromPhone ? true : false,
                    ),

                  if (widget.isFromPhone)
                    // Email Field
                    AppTextfield(
                      controller: _emailController,
                      label: "Email",
                      hintText: 'Enter your email',
                      textInputType: TextInputType.emailAddress,
                      enabled: widget.isFromPhone ? true : false,
                    ),

                  AppTextfield(
                    controller: _dobController,
                    label: 'Date Of Birth',
                    hintText: 'DD-MM-YYYY',
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _dobController.text =
                            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                      }
                    },
                  ),

                  // Country Dropdown
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
                      });
                      if (newValue != null) {
                        await utilProvider.getState(countryId: newValue);
                        setState(() {});
                      }
                    },
                  ),

                  // State Dropdown
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

                  // City Dropdown
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

                  // District Dropdown
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

                  // Salutation
                  AppTextfield(
                    controller: _salutationController,
                    label: "Salutation",
                    hintText: 'Enter your Salutation',
                  ),

                  // Samaj Dropdown
                  AppDropdown<String>(
                    value: selectedSamaj,
                    label: "Samaj",
                    hintText: 'Select your Samaj',
                    isRequired: false,
                    items: utilProvider.samajList.map((samaj) {
                      return DropdownMenuItem<String>(
                        value: samaj.samajId,
                        child: Text(samaj.samajName ?? ''),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSamaj = newValue;
                      });
                    },
                  ),

                  // Sampraday
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _sampradayController,
                      label: "Sampraday",
                      hintText: 'Enter your Sampraday',
                    ),

                  // Upadhi
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _upadhiController,
                      label: "Upadhi",
                      hintText: 'Enter your Upadhi',
                    ),

                  // Sangh
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _sanghController,
                      label: "Sangh",
                      hintText: 'Enter your Sangh',
                    ),

                  // Diksha Place
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _dikshaPlaceController,
                      label: "Diksha Place",
                      hintText: 'Enter your Diksha Place',
                    ),

                  // Diksha Date
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _dikshaDateController,
                      label: 'Diksha Date',
                      hintText: 'DD-MM-YYYY',
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _dikshaDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                        }
                      },
                    ),

                  // Tapasta Detail
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _tapasyaDetailController,
                      label: "Tapasta Detail",
                      hintText: 'Enter your Tapasta Detail',
                    ),

                  // Knowledge Detail
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _knowledgeDetailController,
                      label: "Knowledge Detail",
                      hintText: 'Enter your Knowledge Detail',
                    ),

                  // Vihar Detail
                  if (!widget.isUser)
                    AppTextfield(
                      controller: _viharDetailController,
                      label: "Vihar Detail",
                      hintText: 'Enter your Vihar Detail',
                    ),

                  SizedBox(),

                  // Update Button
                  AppButton(
                    text: "Update",
                    onTap: () async {
                      String formattedDob = "";
                      if (_dobController.text.isNotEmpty) {
                        final parts = _dobController.text.split('-');
                        if (parts.length == 3) {
                          formattedDob =
                              '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
                        }
                      }

                      String formattedDikshaDate = "";
                      if (_dobController.text.isNotEmpty) {
                        final parts = _dikshaDateController.text.split('-');
                        if (parts.length == 3) {
                          formattedDikshaDate =
                              '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
                        }
                      }

                      String? base64Image;
                      if (_pickedImage != null) {
                        final bytes = await File(
                          _pickedImage!.path,
                        ).readAsBytes();
                        base64Image = base64Encode(bytes);
                      }

                      Map<String, dynamic> data = {
                        "firebase_uid": widget.firebaseUid,
                        "name": _nameController.text,
                        "mobile": _phoneController.text,
                        "email": _emailController.text,
                        "dob": formattedDob,
                        "profile_image": base64Image,
                        "samaj": selectedSamaj,
                        "district": selectedDistrict,
                        "city": selectedCity,
                        "state": selectedState,
                        "country": selectedCountry,
                      };

                      Map<String, dynamic> santData = {
                        "firebase_uid": widget.firebaseUid,
                        "name": _nameController.text,
                        "mobile": _phoneController.text,
                        "email": _emailController.text,
                        "dob": formattedDob,
                        "profile_image": base64Image,
                        "samaj": selectedSamaj,
                        "district": selectedDistrict,
                        "city": selectedCity,
                        "state": selectedState,
                        "country": selectedCountry,
                        "gender": _genderController.text,
                        "salutation": _salutationController.text,
                        "sampraday": _sampradayController.text,
                        "upadhi": _upadhiController.text,
                        "sangh": _sanghController.text,
                        "diksha_place": _dikshaPlaceController.text,
                        "diksha_date": formattedDikshaDate,
                        "tapasya_details": _tapasyaDetailController.text,
                        "knowledge_details": _knowledgeDetailController.text,
                        "vihar_details": _viharDetailController.text,
                      };

                      bool registerSuccess;

                      if (widget.isUser) {
                        registerSuccess = await context
                            .read<AuthProvider>()
                            .userRegister(data: data);
                        MySharedPreferences.instance.setBooleanValue(
                          "isUser",
                          widget.isUser,
                        );
                      } else {
                        registerSuccess = await context
                            .read<AuthProvider>()
                            .santRegister(data: santData);
                        MySharedPreferences.instance.setBooleanValue(
                          "isUser",
                          widget.isUser,
                        );
                      }

                      if (registerSuccess) {
                        if (widget.isUser) {
                          navigatorPushReplacement(
                            context,
                            App(isUser: widget.isUser),
                          );
                        } else {
                          navigatorPushReplacement(
                            context,
                            App(isUser: widget.isUser),
                          );
                        }
                      } else {
                        toastMessage('Register failed. Please try again.');
                      }
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
    super.dispose();
  }
}
