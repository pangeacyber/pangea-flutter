import 'package:flutter/material.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',

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
    // Clean up our user data on log out
    authnBrowserClient.clearUserData();
  }

  Widget get _authButton {
    return StreamBuilder<Session?>(
      stream: authnBrowserClient.userBroadcastStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
        VoidCallback? handler = _redirectToLogin;
        dynamic icon = Icons.login_sharp;

        // Only show the log out button if we do not have a session
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
        // If we have a session we can show the user their profile
        if (snapshot.hasData && snapshot.data != null) {
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
                    const Text('Your Account'),
                    _authButton,
                  ],
                ),
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      bgStartColor,
                      bgEndColor,
                    ],
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(
                      fontSize: 12,
                      color:  textColor,
                      fontWeight: FontWeight.normal,
                    ),
                    child: Center(
                      child: UserProfile(userData: snapshot.data),
                    ),
                  )
                )
              )
            );
          }
        
          // By default ask the user to log in
          return Scaffold(
            backgroundColor: bgColor,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    bgStartColor,
                    bgEndColor,
                  ],
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color:  textColor,
                    fontWeight: FontWeight.normal,
                  ),
                  child: Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Image(image: AssetImage("lib/images/manidae-logo-white.png"), width: 200,)
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: _redirectToLogin,
                          child: const Text("Sign In")
                        )
                      ),
                    ],
                  ),
                ),
              )
            )
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyContent;
    
  }
}
