import 'package:firebase_app/model/database.dart';
import 'package:firebase_database/firebase_database.dart';

class Movie {
  final movieId;
  final name;
  final year;
  final playTime;
  final description;
  final img;
  final rating;
  final votes;
  var watched;
  DatabaseReference _id;

  Movie(this.movieId, this.name, this.year, this.playTime, this.description,
      this.img, this.rating, this.votes, this.watched);

  static String check(String value) {
    return value.isEmpty ? 'No data' : value;
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Title not check => title empty = no movie found
    // Poster url not check => no url = print no data (handled in add_new.dart)
    return Movie(
        json['id'],
        json['title'],
        check(json['year']),
        check(json['length']),
        check(json['plot']),
        json['poster'],
        check(json['rating']),
        check(json['rating_votes']),
        false);
  }

  void setId(DatabaseReference id) {
    this._id = id;
  }

  DatabaseReference getId() => this._id;

  Map<String, dynamic> toJson() {
    return {
      'id': this.movieId,
      'name': this.name,
      'year': this.year,
      'playTime': this.playTime,
      'description': this.description,
      'img': this.img,
      'rating': this.rating,
      'votes': this.votes,
      'watched': this.watched
    };
  }

  factory Movie.fromDb(Map<dynamic, dynamic> dbRecord, String ref) {
    return Movie(
        dbRecord['id'],
        dbRecord['name'],
        dbRecord['year'],
        dbRecord['playTime'],
        dbRecord['description'],
        dbRecord['img'],
        dbRecord['rating'],
        dbRecord['votes'],
        dbRecord['watched'])
      ..setId(databaseReference.child(ref));
  }
}
