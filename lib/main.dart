import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/data/account_manager.dart';
import 'package:flutter_app/data/model/account.dart';
import 'package:flutter_app/data/utils.dart';
import 'data/remote/network_service/network_service.dart';
import 'package:flutter/foundation.dart';

NetworkService networkService;

void main() {
  networkService = NetworkService();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _responseText = "Response appears here";
  bool _isRefreshTokenOk = false;

  void _login() async {
    Response response = await networkService.getDio().post(
        "/identity/v1/CustomerIdentity/ConfirmPhoneNumber",
        data: {"userName": "09907473597"}
    );

    final mJson = json.decode(response.data);
    var map = Map<String, dynamic>.from(mJson);

    Account account = new Account();
    account.accessToken = map["Data"]["access_token"];
    account.refreshToken = map["Data"]["refresh_token"];
    account.expiresIn = map["Data"]["expires_in"];
    account.tokenExpiresOn = new DateTime.now()
        .millisecondsSinceEpoch + (account.expiresIn.toInt() * 1000);

    AccountManager().setAccount(account);

    setState(() {
      _isRefreshTokenOk = true;
    });

    print(account.accessToken);
    print(account.refreshToken);
    print(account.expiresIn);
    print(account.tokenExpiresOn);
  }

  void _getInfo() async {
    for (int i = 0; i < 10; i++) {
      Response response = await networkService.getDio().get(
          "/orderSupermarket/v1/Home/Test"
      );

      setState(() {
        _responseText =
            response.data + " " + new DateTime.now().toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: screenAwareSize(18, context),
                right: screenAwareSize(18, context),
                top: screenAwareSize(72, context)
            ),
            child: Text(
              "Flutter App",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: screenAwareSize(18, context),
                right: screenAwareSize(18, context),
                top: screenAwareSize(100, context)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: MaterialButton(
                color: _isRefreshTokenOk ? Color(0x999999) : Color(0xFFFB382F),
                padding: EdgeInsets.symmetric(
                  vertical: screenAwareSize(14.0, context),
                ),
                onPressed: _login,
                child: Align(
                  alignment: Alignment.center,
                  child: Text("Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:
                          screenAwareSize(15.0, context))),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: screenAwareSize(18, context),
                right: screenAwareSize(18, context),
                top: screenAwareSize(18, context)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: MaterialButton(
                color: Color(0xFFFB382F),
                padding: EdgeInsets.symmetric(
                  vertical: screenAwareSize(14.0, context),
                ),
                onPressed: _getInfo,
                child: Align(
                  alignment: Alignment.center,
                  child: Text("Call Service",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:
                          screenAwareSize(15.0, context))),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: screenAwareSize(18, context),
                right: screenAwareSize(18, context),
                top: screenAwareSize(72, context)
            ),
            child: Text(
              '$_responseText',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: "Montserrat-Medium"
              ),
            ),
          ),
        ],
      ),
    );
    /*return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _login,
        tooltip: 'Login',
        child: Icon(Icons.add),
      ),
    );*/
  }
}
