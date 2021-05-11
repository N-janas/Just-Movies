import 'dart:ui';

import 'package:firebase_app/model/bloc_add/add_movie_bloc.dart';
import 'package:firebase_app/model/bloc_add/add_movie_events.dart';
import 'package:firebase_app/model/bloc_add/add_movie_state.dart';
import 'package:firebase_app/model/database.dart';
import 'package:firebase_app/model/movie.dart';
import 'package:firebase_app/model/movie_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

class AddMovieView extends StatefulWidget {
  AddMovieView({Key key}) : super(key: key);

  @override
  _AddMovieViewState createState() => _AddMovieViewState();
}

class _AddMovieViewState extends State<AddMovieView> {
  // Fields
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AddMovieBloc bloc = AddMovieBloc(InitialStateAddMovie(), MovieRepo());

  // Helper function creating appbar with searchbar
  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text('Movie Search'),
      actions: [searchBar.getSearchAction(context)],
    );
  }

  // What to do when request to searchbar is submitted
  void onSubmitted(String value) async {
    // Call fetch event when title was submitted
    bloc.add(FetchMovieFromAPI(value));
  }

  // Searchbar constructor
  _AddMovieViewState() {
    searchBar = new SearchBar(
      inBar: false,
      setState: setState,
      buildDefaultAppBar: buildAppBar,
      onCleared: () {
        print('clear');
      },
      onClosed: () {
        print('closed');
      },
      onSubmitted: onSubmitted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: AddMovieContent(searchBar: searchBar, scaffoldKey: _scaffoldKey),
    );
  }
}

class AddMovieContent extends StatelessWidget {
  const AddMovieContent({
    Key key,
    @required this.searchBar,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  })  : _scaffoldKey = scaffoldKey,
        super(key: key);

  final SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  // Helper function creating content with movie, if movie was found
  Widget buildMovieCard(
      String title,
      String year,
      String playtime,
      String description,
      String imgUrl,
      String rating,
      String votes,
      var ctx,
      Movie movie) {
    return Center(
      child: SizedBox(
        height: 300,
        width: MediaQuery.of(ctx).size.width - 25,
        child: Card(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // If no poster url was found then print info
                    imgUrl.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                            child: Container(
                              child: ClipRRect(
                                child: Image.network(
                                  imgUrl,
                                  loadingBuilder: (ctx, child, progress) {
                                    return progress == null
                                        ? child
                                        : CircularProgressIndicator();
                                  },
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black87,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        : Text(
                            'No poster found',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(22, 15, 10, 5),
                          child: Container(
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 23),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              'Year: $year',
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Length: $playtime',
                              style: TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(21, 0, 0, 0),
                        child: Container(
                          alignment: Alignment.topLeft,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(12, 10, 3, 3),
                            child: SingleChildScrollView(
                              child: Text('Plot description: $description'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25))),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Rating: $rating, Votes: $votes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: Icon(Icons.add_box_outlined,
                                        color: Colors.green[400]),
                                    onPressed: () async {
                                      // try to save movie
                                      final result = await saveMovie(movie);
                                      // if fails it means  it is already in db
                                      if (result == null) {
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Movie is already in database')));
                                      } else {
                                        movie.setId(result);
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                            SnackBar(
                                                content: Text('Movie added')));
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      key: _scaffoldKey,
      body: BlocBuilder<AddMovieBloc, AddMovieState>(
        bloc: BlocProvider.of<AddMovieBloc>(context),
        builder: (context, AddMovieState state) {
          // Handling the states
          if (state is SearchingMovieInAPI)
            return Center(child: CircularProgressIndicator());
          else if (state is InitialStateAddMovie)
            return Center(child: Text('Use searchbar to find movies...'));
          else if (state is MovieIsFound)
            return buildMovieCard(
                state.movie.name,
                state.movie.year,
                state.movie.playTime,
                state.movie.description,
                state.movie.img,
                state.movie.rating,
                state.movie.votes,
                context,
                state.movie);
          else
            return Center(child: Text('No matching items found...'));
        },
      ),
    );
  }
}
