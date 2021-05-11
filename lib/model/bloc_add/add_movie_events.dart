import 'package:equatable/equatable.dart';

class AddMovieEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchMovieFromAPI extends AddMovieEvent {
  final name;

  FetchMovieFromAPI(this.name);

  @override
  List<Object> get props => [this.name];
}
