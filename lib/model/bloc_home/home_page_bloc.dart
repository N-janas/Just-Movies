import 'package:bloc/bloc.dart';
import 'package:firebase_app/model/bloc_home/home_page_events.dart';
import 'package:firebase_app/model/bloc_home/home_page_states.dart';
import 'package:firebase_app/model/database.dart';
import 'package:firebase_app/model/movie.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc(HomePageState initialState) : super(initialState);

  @override
  Stream<HomePageState> mapEventToState(HomePageEvent event) async* {
    if (event is RefreshList) {
      yield LoadingMovieList();

      List<Movie> movies = await getMovies();
      yield MovieListLoaded(movies);
    } else if (event is FilterList) {
      yield LoadingMovieList();

      List<Movie> movies = await getFilteredMovies(event.filterString);
      yield FilteredMovieListLoaded(movies, event.filterString);
    }
  }
}
