import 'package:flutter/material.dart';
import 'package:ichazy/presentation/feed_screen.dart';

class Application extends StatefulWidget {

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {

  @override
  Widget build(BuildContext context) {
    return FeedScreen();
  }
}