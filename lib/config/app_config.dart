import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConfig {
  final String mapApiKey;
  final String awsBaseUrl;
  final String awsCognitoPostUrl;
  final String awsCognitoAppUserName;
  final String awsCognitoAppSecret;

  AppConfig(
      {this.mapApiKey = "", this.awsBaseUrl = "", this.awsCognitoPostUrl = "", this.awsCognitoAppUserName = "", this.awsCognitoAppSecret = ""});

  factory AppConfig.fromJson(Map<String, dynamic> jsonMap) {
    return new AppConfig(
        mapApiKey: jsonMap["map_api_key"],
        awsBaseUrl: jsonMap["aws_base_url"],
        awsCognitoPostUrl: jsonMap["aws_cognito_post_url"],
        awsCognitoAppUserName: jsonMap["aws_cognito_app_user_name"],
        awsCognitoAppSecret: jsonMap["aws_cognito_app_secret"]
    );
  }
}

class SecretLoader {
  final String secretPath;

  SecretLoader({this.secretPath});
  Future<AppConfig> load() {
    return rootBundle.loadStructuredData<AppConfig>(this.secretPath,
        (jsonStr) async {
      final secret = AppConfig.fromJson(json.decode(jsonStr));
      return secret;
    });
  }
}
