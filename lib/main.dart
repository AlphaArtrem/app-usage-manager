import 'dart:html';

import 'package:appusagemanager/screens/add_app_to_track.dart';
import 'package:appusagemanager/screens/home.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List keys = prefs.getKeys().toList();

  BackgroundFetch.finish(taskId);
}

void main(){
  runApp(AppUsageManager());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class AppUsageManager extends StatefulWidget {
  @override
  _AppUsageManagerState createState() => _AppUsageManagerState();
}

class _AppUsageManagerState extends State<AppUsageManager> {

  @override
  void initState()
  {
    super.initState();
    initPlatformState();
  }


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

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE
    ), (String taskId) async {
      backgroundFetchHeadlessTask(taskId);
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }
}
