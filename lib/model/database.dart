import 'package:firebase_database/firebase_database.dart';
import 'movie.dart';
import 'dart:async' show Future;

final databaseReference = FirebaseDatabase(
        databaseURL:
            "https://univfirebaseapp-default-rtdb.europe-west1.firebasedatabase.app/")
    .reference();

// Part of path for user's data in database
var userId = '';

Future<DatabaseReference> saveMovie(Movie movie) async {
  bool canAdd = true;
  await databaseReference
      .child('movies/$userId/')
      .once()
      .then((DataSnapshot snapshot) {
    if (snapshot.value != null) {
      for (var v in Map<String, dynamic>.from(snapshot.value).values) {
        // If found existing movie in DB
        if (v['id'] == movie.movieId) {
          canAdd = false;
          break;
        }
      }
    }
  });

  if (canAdd) {
    var id = databaseReference.child('movies/$userId/').push();
    id.set(movie.toJson());
    return id;
  } else {
    return null;
  }
}

void updateMovie(Movie movie) {
  databaseReference
      .child('movies/$userId/${movie.getId().key}')
      .child('watched')
      .set(movie.watched);
}

Future<bool> deleteMovie(String id) async {
  await databaseReference.child('movies/$userId/$id').remove().then((_) {
    return true;
  });
  return false;
}

Future<List<Movie>> getMovies() async {
  final List<Movie> movies = [];
  await databaseReference
      .child('movies/$userId/')
      .once()
      .then((DataSnapshot snapshot) {
    if (snapshot.value == null)
      return movies;
    else {
      Map<String, dynamic>.from(snapshot.value).forEach((key, value) {
        movies.add(Movie.fromDb(value, key));
      });
      return movies;
    }
  });
  return movies;
}

Future<List<Movie>> getFilteredMovies(String filter) async {
  final List<Movie> movies = [];
  await databaseReference
      .child('movies/$userId/')
      .once()
      .then((DataSnapshot snapshot) {
    if (snapshot.value == null)
      return movies;
    else {
      Map<String, dynamic>.from(snapshot.value).forEach((key, value) {
        if (value['name']
            .toString()
            .toLowerCase()
            .contains(filter.toLowerCase())) {
          movies.add(Movie.fromDb(value, key));
        }
      });
      return movies;
    }
  });
  return movies;
}

// Helper functions for changing path to user's data in database
void setUserId(String uid) {
  userId = uid;
}

void resetUserId() {
  userId = '';
}
