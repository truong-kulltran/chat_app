import 'dart:io';

import 'package:badges/badges.dart';
import 'package:chat_app/network/model/user_info_model.dart';
import 'package:chat_app/screens/authenticator/fill_profile/fill_profile_bloc.dart';
import 'package:chat_app/screens/authenticator/fill_profile/fill_profile_state.dart';
import 'package:chat_app/screens/authenticator/fill_profile/select_student/select_student.dart';
import 'package:chat_app/screens/authenticator/fill_profile/select_student/select_student_bloc.dart';
import 'package:chat_app/utilities/app_constants.dart';
import 'package:chat_app/utilities/shared_preferences_storage.dart';
import 'package:chat_app/widgets/app_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../network/model/student.dart';
import '../../../services/firebase_services.dart';
import '../../../theme.dart';
import '../../../utilities/enum/api_error_result.dart';
import '../../../utilities/screen_utilities.dart';
import '../../../utilities/utils.dart';
import '../../../widgets/animation_loading.dart';
import '../../../widgets/input_field_with_ontap.dart';
import '../../../widgets/primary_button.dart';
import '../../main/main_app.dart';
import 'fill_profile_event.dart';

class FillProfilePage extends StatefulWidget {
  final UserInfoModel userInfo;

  const FillProfilePage({Key? key, required this.userInfo}) : super(key: key);

  @override
  State<FillProfilePage> createState() => _FillProfilePageState();
}

class _FillProfilePageState extends State<FillProfilePage> {
  late FillProfileBloc _fillBloc;

  final _formKey = GlobalKey<FormState>();

  final bool isUserRoll = SharedPreferencesStorage().getUserRole();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  String? username;
  String? email;
  String? phone;
  String? fullName;

  bool _isOnline = true;

  String? _image;
  String studentSSID = '';

  List<Student> listStudent = [];

  @override
  void initState() {
    _fillBloc = BlocProvider.of<FillProfileBloc>(context);

    _fillBloc.state.userData = widget.userInfo;

    _image = widget.userInfo.fileUrl;
    _usernameController.text = widget.userInfo.username ?? '';
    _nameController.text = widget.userInfo.fullName ?? '';
    _emailController.text = widget.userInfo.email ?? '';
    _phoneController.text = widget.userInfo.phone ?? '';
    _image = _fillBloc.state.userData?.fileUrl;
    _usernameController.text = _fillBloc.state.userData?.username ?? '';
    _nameController.text = _fillBloc.state.userData?.fullName ?? '';
    _emailController.text = _fillBloc.state.userData?.email ?? '';
    _phoneController.text = _fillBloc.state.userData?.phone ?? '';

    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fillBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FillProfileBloc, FillProfileState>(
      listenWhen: (preState, curState) {
        return curState.apiError == ApiError.noError;
      },
      listener: (context, curState) {
        if (curState.apiError == ApiError.internalServerError) {
          showCupertinoMessageDialog(
            context,
            'Error!',
            content: 'Internal_server_error',
          );
        }
        if (curState.apiError == ApiError.noInternetConnection) {
          showMessageNoInternetDialog(context);
        }
        if (curState.fillSuccess) {
          showCupertinoMessageDialog(
            context,
            'Your profile has been successfully updated',
            onClose: () {
              _navigateToMainPage();
            },
          );
        }
      },
      builder: (context, state) => _body(context, state),
    );
  }

  Widget _body(BuildContext context, FillProfileState state) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Fill Your Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: state.isLoading
              ? const AnimationLoading()
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _imageAvt(context),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: InputField(
                              context: context,
                              controller: _usernameController,
                              // initText: state.userData?.username,
                              readOnly: true,
                              labelText: 'Username',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: InputField(
                              context: context,
                              controller: _nameController,
                              // initText: state.userData?.fullName,
                              readOnly: false,
                              labelText: 'Full name',
                              hintText: 'Enter full name',
                              prefixIcon: Icons.contacts_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter full name';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: InputField(
                              context: context,
                              controller: _emailController,
                              // initText: state.userData?.email,
                              readOnly: true,
                              labelText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                } else if (!AppConstants.emailExp
                                    .hasMatch(value)) {
                                  return 'Please enter valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: InputField(
                              context: context,
                              controller: _phoneController,
                              // initText: state.userData?.phone,
                              readOnly: false,
                              labelText: 'Phone number',
                              hintText: 'Enter phone number',
                              prefixIcon: Icons.phone,
                              maxText: 10,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (isUserRoll) _selectStudent(),
                          Padding(
                            padding: const EdgeInsets.only(top: 32, bottom: 32),
                            child: PrimaryButton(
                              text: 'Save',
                              onTap: () async =>
                                  await onTapButton(context, state.userData),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> onTapButton(BuildContext context, UserInfoModel? info) async {
    if (_formKey.currentState!.validate()) {
      if (isNullOrEmpty(_image)) {
        showCupertinoMessageDialog(context, 'Image avartar cannot be empty');
      } else {
        showLoading(context);
        List<int?> listStudentIdSelected =
            listStudent.map((e) => e.id).toList();

        String image = '';

        if (!_isOnline) {
          image = await FirebaseService().uploadImageToStorage(
            titleName:
                'image_profile_${SharedPreferencesStorage().getUserId()}',
            childFolder: AppConstants.imageProfilesChild,
            image: File(_image!),
          );
        }

        final Map<String, dynamic> userMap = {
          "fileUrl": _isOnline ? info?.fileUrl : image,
          "fullName": _nameController.text.trim(),
          "isFillProfileKey": true,
          "phone": _phoneController.text.trim(),
          "studentIds": listStudentIdSelected
        };
        _fillBloc.add(FillProfile(userMap: userMap));
      }
    }
  }

  void _navigateToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainApp(currentTab: 0)),
    );
  }

  Widget _selectStudent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          final List<Student> students = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => SelectStudentBloc(context),
                child: SelectStudent(students: listStudent),
              ),
            ),
          );

          setState(() {
            listStudent = students;
          });
        },
        child: Badge(
          showBadge: listStudent.isNotEmpty,
          badgeContent: Text(
            listStudent.length.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          badgeStyle: const BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
          ),
          position: BadgePosition.topEnd(top: -5, end: -8),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.withOpacity(0.05),
              border: Border.all(
                width: 1,
                color: const Color.fromARGB(128, 130, 130, 130),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 16),
                  child: Icon(
                    Icons.group,
                    size: 24,
                    color: AppColors.greyLight,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Student\'s Parent',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    Icons.navigate_next,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(String value) {
    return DateFormat('dd-MM-yyyy').format(DateTime.tryParse(value)!);
  }

  Widget _imageAvt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: AppImage(
                isOnline: _isOnline,
                localPathOrUrl: _image,
                height: 200,
                width: 200,
                boxFit: BoxFit.cover,
                errorWidget: Image.asset(
                  'assets/images/ic_account_circle.png',
                  color: Colors.grey.withOpacity(0.6),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: () async => await showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                          onPressed: () async {
                            Navigator.pop(context);

                            final imagePicked = await pickPhoto(
                              ImageSource.camera,
                            );

                            setState(() {
                              _image = imagePicked;
                              _isOnline = false;
                            });
                          },
                          child: Text(
                            'Take a photo from camera',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () async {
                            Navigator.pop(context);

                            final imagePicked =
                                await pickPhoto(ImageSource.gallery);

                            setState(() {
                              _image = imagePicked;
                              _isOnline = false;
                            });
                          },
                          child: Text(
                            'Choose a photo from gallery',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
