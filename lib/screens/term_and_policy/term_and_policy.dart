import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/database.dart';
import '../../utilities/app_constants.dart';
import '../../utilities/screen_utilities.dart';
import '../../widgets/custom_check_box.dart';
import '../../widgets/primary_button.dart';
import '../onboarding/onboarding_screen.dart';

class TermPolicyPage extends StatefulWidget {
  const TermPolicyPage({Key? key}) : super(key: key);

  @override
  State<TermPolicyPage> createState() => _TermPolicyPageState();
}

class _TermPolicyPageState extends State<TermPolicyPage> {
  bool _isRead = false;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(16, padding.top, 16, 16 + padding.bottom),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 60, bottom: 36),
              child: Text(
                'Term and Policy',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 450,
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 230, 230, 230),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: const SingleChildScrollView(
                child: Text(
                  AppConstants.longText,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isRead = !_isRead;
                  });
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 21,
                      height: 21,
                      child: CustomCheckBox(
                        value: _isRead,
                        onChanged: (value) {
                          setState(() {
                            _isRead = value;
                          });
                        },
                      ),
                    ),
                    const Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Agree. I have read and understood',
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                    ))
                  ],
                ),
              ),
            ),
            const Spacer(),
            _nextButton(),
          ],
        ),
      ),
    );
  }

  Widget _nextButton() {
    handleTap() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool(AppConstants.agreedWithTermsKey, true);
      bool isFirstTimeOpenApp =
          preferences.getBool(AppConstants.firstTimeOpenKey) ?? false;
      if (isFirstTimeOpenApp) {
        preferences.setBool(AppConstants.firstTimeOpenKey, false);
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const OnBoardingPage()));
        }
      } else {
        if (DatabaseService().chatKey != null) {
          if (mounted) {
            backToChat(context);
          }
        } else {
          if (mounted) {
            //todo: remove test
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const OnBoardingPage()));
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => BlocProvider<TabBloc>(
            //       create: (BuildContext context) => TabBloc(),
            //       child: MainApp(navFromStart: true),
            //     ),
            //   ),
            // );

          }
        }
      }
      return null;
    }

    return PrimaryButton(
      text: 'Next',
      isDisable: !_isRead,
      onTap: _isRead ? handleTap : null,
    );
  }
}
