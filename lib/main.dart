import 'package:appusagemanager/screens/add_app_to_track.dart';
import 'package:appusagemanager/screens/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AppUsageManager());
}

class AppUsageManager extends StatefulWidget {
  @override
  _AppUsageManagerState createState() => _AppUsageManagerState();
}

class _AppUsageManagerState extends State<AppUsageManager> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Usage Manager',
      debugShowCheckedModeBanner: false,
      home: Home(),
      routes: {
        'addAppToTrack' : (context) => AddAppToTrack(),
      },
    );
  }
}
