import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/classes/database.dart';
import 'package:appusagemanager/screens/add_app_to_track.dart';
import 'package:appusagemanager/screens/home.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

void backgroundFetchUsageData(){
  Workmanager.executeTask((taskName, inputData) async{
    final _database = TrackedAppsDatabase.instance;
    int _rowCount;
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
    }

    return Future.value(true);
  });
}

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
    Workmanager.initialize(
      backgroundFetchUsageData,
      isInDebugMode: true,
    );
    Workmanager.registerPeriodicTask('abc', 'data');

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
