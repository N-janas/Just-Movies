import 'package:bloc/bloc.dart';
import 'package:firebase_app/model/bloc_add/add_movie_events.dart';
import 'package:firebase_app/model/bloc_add/add_movie_state.dart';
import 'package:firebase_app/model/movie.dart';
import 'package:firebase_app/model/movie_repo.dart';

class AddMovieBloc extends Bloc<AddMovieEvent, AddMovieState> {
  MovieRepo movieRepo;

  AddMovieBloc(AddMovieState initialState, this.movieRepo)
      : super(initialState);

  @override
  Stream<AddMovieState> mapEventToState(AddMovieEvent event) async* {
    if (event is FetchMovieFromAPI) {
      yield SearchingMovieInAPI();

      try {
        Movie movie = await movieRepo.getMovie(event.name);
        if ((movie.name as String).isEmpty)
          yield MovieIsNotFound();
        else
          yield MovieIsFound(movie);
      } catch (_) {
        yield MovieIsNotFound();
      }
    }
  }
}
