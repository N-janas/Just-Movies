import 'package:equatable/equatable.dart';
import 'package:firebase_app/model/movie.dart';

class AddMovieState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialStateAddMovie extends AddMovieState {}

class SearchingMovieInAPI extends AddMovieState {}

class MovieIsFound extends AddMovieState {
  final Movie movie;

  MovieIsFound(this.movie);

  @override
  List<Object> get props => [this.movie];
}

class MovieIsNotFound extends AddMovieState {}
