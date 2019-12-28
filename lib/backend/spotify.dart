import 'dart:convert';

import 'package:http/http.dart';
import 'package:spotify_queue/backend/platform.dart';

Client client = new Client();

Future<Map<String, dynamic>> getSearchResults(
    String query, String token) async {
  // Allows query with spaces
  if (query.contains(' ')) {
    query.replaceAll(' ', '%20');
  }

  Map<String, dynamic> map;
  return client
      .get(
          'https://api.spotify.com/v1/search?q=' +
              query +
              '&type=track&market=US',
          headers: authHeaders(token))
      .then<Map<String, dynamic>>((Response response) {
    if (response.body != '' && response.statusCode == 200) {
      map = json.decode(response.body)['tracks'];
    } else if (response.statusCode == 401) {
      // Token expired
      login();
      print(token);
      print(response.body);
      return null;
    } else {
      throw 'Invalid Response';
    }
    return map;
  }).catchError((Object error) => print(error));
}

Future<Map<String, dynamic>> getUserData(String authToken) async {
  Map<String, dynamic> map;
  return client
      .get('https://api.spotify.com/v1/me', headers: authHeaders(authToken))
      .then<Map<String, dynamic>>((Response response) {
    if (response.body != '' && response.statusCode == 200) {
      map = json.decode(response.body);
    } else {
      throw 'Invalid Response';
    }
    return map;
  }).catchError((Object error) =>
          <String, dynamic>{'display_name': 'Unable to retrieve username'});
}

Map<String, String> authHeaders(String token) {
  return <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
}
