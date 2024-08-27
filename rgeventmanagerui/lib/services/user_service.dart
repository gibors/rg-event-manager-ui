
import 'package:dio/dio.dart';
import 'package:rg_event_management_ui/Album.dart';

class UserService {

 Future<Album> fetchAlbum() async {
  final response = await Dio().get('https://jsonplaceholder.typicode.com/albums/1');

  
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(response.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
}