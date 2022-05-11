import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:riderapp/config/app_config.dart';
import 'package:riderapp/models/user.dart';
import 'package:riderapp/providers/car.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _appToken;
  DateTime _appTokenExpiryDate;
  String _token;
  DateTime _expiryDate;
  User _user;
  Timer _authTimer;
  AppConfig _appConfig;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get mapApiKey {
    return _appConfig.mapApiKey;
  }

  String get awsCognitoPostUrl {
    return _appConfig.awsCognitoPostUrl;
  }

  String get awsBaseUrl {
    return _appConfig.awsBaseUrl;
  }

  String get awsCognitoAppUserName {
    return _appConfig.awsCognitoAppUserName;
  }

  String get awsCognitoAppSecret {
    return _appConfig.awsCognitoAppSecret;
  }

  User get user {
    return _user;
  }

  Future<void> _getAppToken() async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$awsCognitoAppUserName:$awsCognitoAppSecret'));
    print(awsCognitoPostUrl);
    try {
      final response = await http.post(
        Uri.parse(awsCognitoPostUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'authorization': basicAuth
        },
        encoding: Encoding.getByName('utf-8'),
        body: {
          'grant_type': 'client_credentials',
          'scope': 'users/post',
        },
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _appToken = responseData['access_token'];
      _appTokenExpiryDate = DateTime.now().add(
        Duration(
          seconds: responseData['expires_in'],
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      final appData = json.encode(
        {
          'token': _appToken,
          'expiryDate': _appTokenExpiryDate.toIso8601String(),
        },
      );
      prefs.setString('appData', appData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> _signUp(
      String email, String name, String password, String icon) async {
    final url = awsBaseUrl + '/user';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': _appToken
        },
        body: json.encode(
            {'email': email, 'password': password, 'name': name, 'iconKey': icon}),
      );
      print(response.statusCode.toString() + " -> " + response.body);
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['message'].join(','));
      }
      return _authenticate(name, password);
    } catch (error) {
      throw error;
    }
  }

  Future<User> _getUser(String token) async {
    final getUserUrl = awsBaseUrl + '/user';
    try {
      final response = await http.get(
        Uri.parse(getUserUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      print(response.statusCode.toString() + " -> " + response.body);
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['message'].join(','));
      }
      return User(
          id: responseData['id'],
          name: responseData['name'],
          email: responseData['email'],
          iconKey: responseData['iconKey']);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> _authenticate(String name, String password) async {
    final authenticateUrl = awsBaseUrl + '/user/authenticate';
    try {
      final response = await http.post(
        Uri.parse(authenticateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _appToken
        },
        body: json.encode({
          'name': name,
          'password': password,
        }),
      );
      print(response.statusCode.toString() + " -> " + response.body);
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['message'].join(','));
      }
      _token = responseData['idToken'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: responseData['expiresIn'],
        ),
      );

      // get user details
      _user = await _getUser(token);

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'expiryDate': _expiryDate.toIso8601String(),
          'name': user.name,
          'id': user.id,
          'iconKey': user.iconKey,
          'email': user.email
        },
      );
      prefs.setString('userData', userData);
      _autoLogout();
      notifyListeners();
      return true;
    } catch (error, stacktrace) {
      print(error.toString());
      return Future.error(error.toString());
    }
  }

  Future<bool> signup(
      String email, String name, String password, String icon) async {
    return _signUp(email, name, password, icon);
  }

  Future<bool> login(String email, String password) async {
    return _authenticate(email, password);
  }

  Future<void> tryAndGetAppToken(SharedPreferences prefs) {
    if (!prefs.containsKey('appData')) {
      _getAppToken();
    } else {
      final extractedAppData =
          json.decode(prefs.getString('appData')) as Map<String, Object>;
      print(extractedAppData);
      final expiryDate = DateTime.parse(extractedAppData['expiryDate']);

      if (expiryDate.isBefore(DateTime.now())) {
        _getAppToken();
      } else {
        _appToken = extractedAppData['token'];
        _appTokenExpiryDate = expiryDate;
      }
    }
  }

  Future<User> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return null;
    }
    final userData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    return User(
      id: userData['id'],
      name: userData['name'],
      iconKey: userData['iconKey'],
      email: userData['email'],
    );
  }

  Future<bool> tryAutoLogin() async {
    _appConfig = await SecretLoader(secretPath: "secrets.json").load();

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      tryAndGetAppToken(prefs);
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    print(extractedUserData);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      tryAndGetAppToken(prefs);
      return false;
    }
    _token = extractedUserData['token'];
    _user = new User(
        id: extractedUserData['id'],
        email: extractedUserData['email'],
        iconKey: extractedUserData['iconKey'],
        name: extractedUserData['name']
    );
    _expiryDate = expiryDate;
    notifyListeners();
    //_autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }


}
