import 'package:firebase_app/model/bloc_home/home_page_bloc.dart';
import 'package:firebase_app/model/bloc_home/home_page_events.dart';
import 'package:firebase_app/model/bloc_home/home_page_states.dart';
import 'package:firebase_app/model/database.dart';
import 'package:firebase_app/model/movie.dart';
import 'package:firebase_app/view/add_new.dart';
import 'package:firebase_app/view/authentication_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

class MyHomePage extends StatefulWidget {
  User user;
  MyHomePage({Key key, this.user}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(this.user);
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TabController _tabController;
  final User user;
  HomePageBloc bloc = HomePageBloc(InitialStateHomePage());

  _MyHomePageState(this.user);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => bloc..add(RefreshList()),
        child: MovieList(user: user, bloc: bloc));
  }
}

class MovieList extends StatefulWidget {
  const MovieList({Key key, @required this.user, this.bloc}) : super(key: key);

  final User user;
  final HomePageBloc bloc;

  @override
  _MovieListState createState() => _MovieListState(bloc);
}

class _MovieListState extends State<MovieList> {
  // Fields
  HomePageBloc bloc;
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

// Helper function creating appbar with searchbar
  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text('Just Movies'),
      actions: [searchBar.getSearchAction(context)],
    );
  }

  // What to do when request to searchbar is submitted
  void onSubmitted(String value) async {
    if (value.isEmpty && bloc.state is MovieListLoaded) {
      // If value is empty and no filter is applied then just do not refresh
      print('do nothing');
    } else if (value.isEmpty) {
      // If value empty return to default view
      bloc.add(RefreshList());
    } else {
      // If value was provided then filter it
      bloc.add(FilterList(value));
    }
  }

  _MovieListState(HomePageBloc bloc) {
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
    this.bloc = bloc;
  }

  Widget generateMovieCard(Movie movie, ctx) {
    return Card(
      child: ListTileTheme(
        tileColor: Colors.grey[50],
        child: ExpansionTile(
          leading: (movie.img as String).isNotEmpty
              ? Image.network(
                  movie.img,
                  loadingBuilder: (ctx, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(7, 0, 0, 0),
                  child: Icon(Icons.image_not_supported_sharp)),
          title: Text(
            movie.name,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              // Delete movie then refresh list in home page
              await deleteMovie(movie.getId().key);
              // If list was filtered then go back to filtered after deletion
              // otherwise refresh
              if (bloc.state is FilteredMovieListLoaded) {
                BlocProvider.of<HomePageBloc>(ctx).add(
                    FilterList((bloc.state as FilteredMovieListLoaded).filter));
              } else {
                BlocProvider.of<HomePageBloc>(ctx).add(RefreshList());
              }
            },
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(16, 2, 5, 0),
                child: Text('Plot - ${movie.description}')),
            Padding(
                padding: EdgeInsets.fromLTRB(16, 1, 5, 0),
                child: Text('Production year : ${movie.year}')),
            Padding(
                padding: EdgeInsets.fromLTRB(16, 1, 5, 0),
                child: Text('Playtime : ${movie.playTime}')),
            Padding(
                padding: EdgeInsets.fromLTRB(16, 1, 5, 2),
                child:
                    Text('Ratings : ${movie.rating} (${movie.votes} votes)')),
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            Container(
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Movie watched ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: movie.watched,
                        onChanged: (newWatchState) {
                          setState(() {
                            movie.watched = !movie.watched;
                          });
                          // Update in db
                          updateMovie(movie);
                        },
                        activeColor: Colors.green,
                        activeTrackColor: Colors.lightGreenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateMovieListView(List<Movie> movieList, ctx) {
    final List<Widget> movieListView = [];

    movieListView.clear();
    for (var movie in movieList) {
      movieListView.add(generateMovieCard(movie, ctx));
    }

    return movieListView.isEmpty
        ? [
            Container(
                alignment: Alignment.center,
                child: Center(child: Text('No movies found')))
          ]
        : movieListView;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 140,
              child: DrawerHeader(
                child: ListView(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.account_circle,
                          size: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            'Logged User',
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.w400),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${this.widget.user.email}',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Logout Button
            ListTile(
              title: Text('Logout'),
              leading: Icon(
                Icons.logout,
                size: 27,
              ),
              onTap: () async {
                // Logout user also from DB
                resetUserId();
                // Logout from app
                FirebaseAuth.instance.signOut().whenComplete(() {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => AuthenticationView()));
                });
              },
            )
          ],
        ),
      ),
      body: BlocBuilder<HomePageBloc, HomePageState>(
        bloc: BlocProvider.of<HomePageBloc>(context),
        builder: (context, HomePageState state) {
          if (state is LoadingMovieList)
            return Center(child: CircularProgressIndicator());
          else if (state is MovieListLoaded)
            return ListView(
              padding: EdgeInsets.fromLTRB(7, 10, 7, 80),
              children: generateMovieListView(state.movies, context),
            );
          else if (state is FilteredMovieListLoaded)
            return ListView(
              padding: EdgeInsets.fromLTRB(7, 10, 7, 80),
              children: generateMovieListView(state.movies, context),
            );
          else
            return Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Change view to adding movie view
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMovieView(),
            ),
          );
          // After trying to add movie refresh list
          BlocProvider.of<HomePageBloc>(context).add(RefreshList());
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}
