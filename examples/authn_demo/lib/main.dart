import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangea_sdk/pangea_sdk.dart';

import 'pages/user_profile.dart';
import 'service._locator.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const SafeArea(top: false, bottom: false, child: MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _redirectToLogin() {
    authnBrowserClient.redirectToLogin();
  }

  void _logOut() async {
    // Clear the SDK state
    authnBrowserClient.clearUserData();
  }

  Widget get _authButton {
    return StreamBuilder<Session?>(
      stream: authnBrowserClient.userBroadcastStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
        VoidCallback? handler = _redirectToLogin;
        dynamic icon = Icons.login_sharp;

        if (authnBrowserClient.session != null) {
          handler = _logOut;
          icon = Icons.logout_sharp;
        }
        return TextButton(
          onPressed: handler,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget get _bodyContent {
    return StreamBuilder<Session?>(
      stream: authnBrowserClient.userBroadcastStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return UserProfile(userData: snapshot.data);
        }

        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              
            Text(
              'You are not logged in yet, please use the button above to login.',
              style: TextStyle(
                fontSize: 16,
                color: textColor
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: highlightColor,
          foregroundColor: textColor,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Home'),
              _authButton,
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color:  textColor,
              fontWeight: FontWeight.normal,
            ),
            child: Center(
              child: _bodyContent,
            ),
          )
        )
      );
  }
}
