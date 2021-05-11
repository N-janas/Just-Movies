import 'package:firebase_app/model/database.dart';
import 'package:firebase_app/view/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationView extends StatefulWidget {
  AuthenticationView({Key key}) : super(key: key);

  @override
  _AuthenticationViewState createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // Form key to later allow validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text(
                    'Just Movies',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 40,
                        fontFamily: 'Times new roman'),
                  ),
                ),
                // Sized box for space
                SizedBox(height: 40),
                // Login/Regiter form
                Form(
                  key: _formKey,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.all(27),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Text label
                          Container(
                            child: Text(
                              'Sign in / Sign up to this application',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey),
                            ),
                            alignment: Alignment.center,
                          ),
                          // Email text field
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                hintText: 'Email Address', labelText: 'Email'),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your email';
                              return null;
                            },
                          ),
                          // Password text field
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                                hintText: 'Enter Password',
                                labelText: 'Password'),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your password';
                              else if (value.length < 6)
                                return 'Password must be at least 6 characters';
                              return null;
                            },
                            obscureText: true,
                          ),
                          SizedBox(height: 30),
                          // Login button
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _signIn();
                              }
                            },
                            child: Text('Sign in'),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side:
                                      BorderSide(color: Colors.deepPurple[600]),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.deepPurple[600]),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Register button
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _signUp();
                              }
                            },
                            child: Text('Sign up'),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side:
                                      BorderSide(color: Colors.deepPurple[300]),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.deepPurple[300]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _signIn() async {
    try {
      // Try to verify user
      final User user = (await _auth.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text))
          .user;

      // Set DB user as current user
      setUserId(user.uid);

      // If success change to main page (login)
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return MyHomePage(
          user: user,
        );
      }));
    } catch (e) {
      // Make toast if failed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to sign in')));
    }
  }

  void _signUp() async {
    try {
      final User user = (await _auth.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text))
          .user;

      // If successfully registered
      if (user != null) {
        // Set DB user as current user
        setUserId(user.uid);

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
          return MyHomePage(
            user: user,
          );
        }));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in. ${e.message}')));
    }
  }
}
