import 'package:equatable/equatable.dart';
import 'package:firebase_app/model/movie.dart';

class HomePageState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialStateHomePage extends HomePageState {}

class MovieListLoaded extends HomePageState {
  final List<Movie> movies;

  MovieListLoaded(this.movies);

  @override
  List<Object> get props => [this.movies];
}

class FilteredMovieListLoaded extends HomePageState {
  final List<Movie> movies;
  final String filter;

  FilteredMovieListLoaded(this.movies, this.filter);

  @override
  List<Object> get props => [this.movies, this.filter];
}

class LoadingMovieList extends HomePageState {}
