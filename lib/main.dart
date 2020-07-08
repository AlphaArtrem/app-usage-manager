import 'package:appusagemanager/screens/add_app_to_track.dart';
import 'package:appusagemanager/screens/home.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String payload) async{});

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'staticAlert', 'Check Usage Remainder', 'Static alert to check app usage',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'Check Usage', 'Track your app usage details', platformChannelSpecifics,
      payload: null);

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
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }
}
