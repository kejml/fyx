import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/theme/T.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  try {
    var credentials = await ApiController().provider.getCredentials();
    return runApp(FyxApp(credentials));
  } catch (error) {
    return runApp(FyxApp(null));
  }
}

class FyxApp extends StatelessWidget {
  final Credentials _credentials;

  const FyxApp(this._credentials, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide the keyboard on tap
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: PlatformApp(
        title: 'Fyx',
        theme: PlatformThemeData(primaryColor: T.COLOR_PRIMARY),
        home: _credentials is Credentials && _credentials.isValid ? HomePage() : LoginPage(),
      ),
    );
  }
}
