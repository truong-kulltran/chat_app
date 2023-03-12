import 'package:chat_app/screens/authenticator/login/login_bloc.dart';
import 'package:chat_app/screens/authenticator/login/login_page.dart';
import 'package:chat_app/screens/authenticator/signup/sign_up_bloc.dart';
import 'package:chat_app/screens/authenticator/signup/sign_up_event.dart';
import 'package:chat_app/screens/authenticator/signup/sign_up_state.dart';
import 'package:chat_app/widgets/primary_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../network/repository/sign_up_repository.dart';
import '../../../network/response/base_response.dart';
import '../../../utilities/app_constants.dart';
import '../../../utilities/screen_utilities.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/input_password_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final focusNode = FocusNode();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isShowPassword = false;
  bool _isShowConfirmPassword = false;
  bool _isNotMatch = false;

  String validateMessage = '';

  late SignUpBloc _signUpBloc;
  late SignUpRepository _signUpRepository;

  @override
  void initState() {
    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _signUpBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _registerForm(padding, height),
            _goToLoginPage(),
          ],
        ),
      ),
    );
  }

  Widget _registerForm(EdgeInsets padding, double height) {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      if (state is SignupLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (state is SignupSuccess) {
        showSuccessBottomSheet(
          context,
          titleMessage: state.message ?? '',
          contentMessage:
              'You have successfully sign up an account, please login',
          buttonLabel: 'Login',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<LoginFormBloc>(
                  create: (context) => LoginFormBloc(context),
                  child: IDPassLoginForm(),
                ),
              ),
            );
          },
        );
      }
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          top: padding.top,
          right: 16,
          bottom: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: height - 120,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/app_logo_light.png',
                          height: 150,
                          width: 150,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Welcome sign up to \'app name\'',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _inputTextField(
                    hintText: 'Enter username',
                    controller: _userNameController,
                    keyboardType: TextInputType.text,
                    iconLeading: Icon(
                      Icons.person_outline,
                      color: AppConstants().greyLight,
                      size: 24,
                    ),
                  ),
                  _inputTextField(
                    hintText: 'Enter email',
                    controller: _emailController,
                    keyboardType: TextInputType.text,
                    iconLeading: Icon(
                      Icons.mail_outline,
                      color: AppConstants().greyLight,
                      size: 24,
                    ),
                  ),
                  _inputPasswordField(
                    hintText: 'Enter password',
                    controller: _passwordController,
                    obscureText: !_isShowPassword,
                    onTapSuffixIcon: () {
                      setState(() {
                        _isShowPassword = !_isShowPassword;
                      });
                    },
                  ),
                  _inputPasswordField(
                    hintText: 'Confirm password',
                    controller: _confirmPasswordController,
                    obscureText: !_isShowConfirmPassword,
                    onTapSuffixIcon: () {
                      setState(() {
                        _isShowConfirmPassword = !_isShowConfirmPassword;
                      });
                    },
                  ),
                  _passwordNotMatch(),
                ],
              ),
            ),
            _buttonSignUp(state)
          ],
        ),
      );
    });
  }

  Widget _buttonSignUp(SignUpState currentState) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: PrimaryButton(
        text: 'Sign Up',
        onTap: () async {
          ConnectivityResult connectivityResult =
              await Connectivity().checkConnectivity();
          if (connectivityResult == ConnectivityResult.none && mounted) {
            showMessageNoInternetDialog(context);
          } else {
            _signUpBloc.add(
              SignupButtonPressed(
                // username: _userNameController.text.trim(),
                // email: _emailController.text.trim(),
                // password: _passwordController.text.trim(),
                email: 'truong@gmail.com',
                username: 'truong1',
                password: '123456'
              ),
            );
          }
        },
      ),
    );
  }

  Widget _passwordNotMatch() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10),
      child: Row(
        children: [
          Image.asset(
            'assets/images/ic_x_red.png',
            height: 20,
            width: 20,
            color: const Color(0xffCA0000),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'error',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xffCA0000),
                fontWeight: FontWeight.normal,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _inputTextField({
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    Icon? iconLeading,
    String? prefixIconPath,
    int? maxText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        child: Input(
          keyboardType: keyboardType,
          maxText: maxText,
          controller: controller,
          onChanged: (text) {
            //_validateForm();
          },
          textInputAction: TextInputAction.next,
          onSubmit: (_) => focusNode.requestFocus(),
          hint: hintText,
          prefixIconPath: prefixIconPath,
          prefixIcon: iconLeading,
        ),
      ),
    );
  }

  Widget _inputPasswordField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    Function? onTapSuffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        child: InputPasswordField(
          isInputError: false,
          obscureText: obscureText,
          onTapSuffixIcon: onTapSuffixIcon,
          keyboardType: TextInputType.text,
          controller: controller,
          onChanged: (text) {},
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => focusNode.requestFocus(),
          hint: hintText,
          prefixIconPath: 'assets/images/ic_lock.png',
        ),
      ),
    );
  }

  Widget _goToLoginPage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<LoginFormBloc>(
                    create: (context) => LoginFormBloc(context),
                    child: IDPassLoginForm(),
                  ),
                ),
              );
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _validateSignup() {
    RegExp emailExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    RegExp passwordExp =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');

    if (!emailExp.hasMatch(_emailController.text.trim())) {
      validateMessage = AppConstants.emailNotMatch;
      return false;
    }
    if (!passwordExp.hasMatch(_passwordController.text.trim())) {
      validateMessage = AppConstants.passwordNotMatch;
      return false;
    }
    if (!emailExp.hasMatch(_emailController.text.trim()) &&
        !passwordExp.hasMatch(_passwordController.text.trim())) {
      validateMessage = AppConstants.emailPasswordNotMatch;
      return false;
    }
    return true;
  }
}
