import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'movie.dart';

class MovieRepo {
  // Singleton
  static final MovieRepo _instance = MovieRepo._();

  factory MovieRepo() {
    return _instance;
  }

  MovieRepo._();
  //

  final domain = 'imdb-internet-movie-database-unofficial.p.rapidapi.com';
  final more = '/film/';

  Future<Movie> getMovie(String name) async {
    var jsonStr = await rootBundle.loadString('assets/secrets.json');
    final apiKey = json.decode(jsonStr)['movie_api_key'];

    final result =
        await http.Client().get(Uri.https(domain, more + name), headers: {
      'x-rapidapi-key': apiKey,
      'x-rapidapi-host':
          'imdb-internet-movie-database-unofficial.p.rapidapi.com'
    });

    if (result.statusCode != 200) throw Exception();

    final response = json.decode(result.body);
    return Movie.fromJson(response);
  }
}
