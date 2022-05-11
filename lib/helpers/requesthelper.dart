import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestHelper{


  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    try{
      if(response.statusCode == 200){
        String data = response.body;
        var decodedData = jsonDecode(data);
        return decodedData;
      }
      else{
        print(response.statusCode);
        print(response.body);
        return 'failed';
      }
    }
    catch(e){
      return 'failed';
    }


  }

}