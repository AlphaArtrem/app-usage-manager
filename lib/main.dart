import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/classes/database.dart';
import 'package:appusagemanager/common/functions.dart';
import 'package:appusagemanager/screens/add_app_to_track.dart';
import 'package:appusagemanager/screens/home.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future selectNotification(String payload) async {
}

Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
}

void backgroundFetch(String taskId) async{
  final _database = TrackedAppsDatabase.instance;
  int _rowCount = 0;
  List<Map<String, dynamic>> _trackedAppsData;
  Map<String, double> _trackedAppsTime = {};
  List _trackedApps = [];
  Map<String, double> _appUsage;

  _rowCount = await _database.getRowCount();
  if(_rowCount > 0){
    _trackedAppsData = await _database.getAllRows();

    for(int i = 0 ; i < _trackedAppsData.length; i++){
      _trackedAppsTime[_trackedAppsData[i][TrackedAppsDatabase.columnPackage]] = _trackedAppsData[i][TrackedAppsDatabase.columnTime];
    }

    await DeviceApps.getInstalledApplications(onlyAppsWithLaunchIntent: true, includeAppIcons: true).then((apps) {
      _trackedApps = apps;
    });

    AppUsage appUsage = new AppUsage();
    try {
      // Define a time interval
      DateTime endDate = new DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

      // Fetch the usage stats
      Map<String, double> usage = await appUsage.fetchUsage(startDate, endDate);

      _appUsage = usage;
      _trackedApps = _trackedApps.where((app) => _appUsage.keys.toList().contains(app.packageName)).toList();

      List<String> trackedAppsPackages = [];

      for(int i = 0 ; i < _trackedAppsData.length; i++){
        trackedAppsPackages.add(_trackedAppsData[i][TrackedAppsDatabase.columnPackage]);
      }
      _trackedApps = _trackedApps.where((app) => trackedAppsPackages.contains(app.packageName.toString())).toList();

    }
    on AppUsageException catch (exception) {
      print(exception);
    }

    WidgetsFlutterBinding.ensureInitialized();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'AppUsage', 'AppUsageNotification', 'AppUsageExceededNotification',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);


    for(int i = 0; i < _trackedApps.length; i++){
      if( _trackedAppsTime[_trackedApps[i].packageName] <= _appUsage[_trackedApps[i].packageName]){
        double exceededBy = _appUsage[_trackedApps[i].packageName] -  _trackedAppsTime[_trackedApps[i].packageName];
        String title = 'Overused ${_trackedApps[i].appName.toString()}';
        String body = 'Exceeded Usage Of ${_trackedApps[i].appName.toString()} by ${formatTime(exceededBy)}';
        await flutterLocalNotificationsPlugin.show(
          0,
          title.toString(),
          body.toString(),
          platformChannelSpecifics,
        );
      }
    }
  }

  BackgroundFetch.finish(taskId);
}

void main(){
  runApp(AppUsageManager());
  BackgroundFetch.registerHeadlessTask(backgroundFetch).then((value) => print("headless"));
}

class AppUsageManager extends StatefulWidget {
  @override
  _AppUsageManagerState createState() => _AppUsageManagerState();
}

class _AppUsageManagerState extends State<AppUsageManager> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 15,
      forceAlarmManager: false,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
    ), backgroundFetch).then((int status) {
      print('[BackgroundFetch] configure success: $status');

    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
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
}
