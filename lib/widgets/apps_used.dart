import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/classes/database.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:appusagemanager/common/functions.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

Future selectNotification(String payload) async {
}

Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
}

void backgroundFetch(){
  Workmanager.executeTask((task, inputData) async{
    final _database = TrackedAppsDatabase.instance;
    int _rowCount = 0;
    List<Map<String, dynamic>> _trackedAppsData;
    Map<String, double> _trackedAppsTime = {};
    List _trackedApps = [];
    Map<String, double> _appUsage;

    _rowCount = await _database.getRowCount();
    print(_rowCount);
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
            String title = 'Overused ${_trackedApps[i].appName.toString()}';
            String body = 'Exceded Usage Of ${_trackedApps[i].appName.toString()} by '
                '${formatTime(_appUsage[_appUsage[_trackedApps[i].packageName] -  _trackedAppsTime[_trackedApps[i].packageName]])}';
          await flutterLocalNotificationsPlugin.show(
            0,
            title.toString(),
            body.toString(),
            platformChannelSpecifics,
          );
        }
      }
    }

    return Future.value(true);
  });
}

class AppsUsedToday extends StatefulWidget {
  @override
  _AppsUsedTodayState createState() => _AppsUsedTodayState();
}

class _AppsUsedTodayState extends State<AppsUsedToday> {
  List _installedApps = [];
  Map<String, double> _appUsage;

  void setup() async{
    await DeviceApps.getInstalledApplications(onlyAppsWithLaunchIntent: true, includeAppIcons: true).then((apps) {
      _installedApps = apps;
    });

    AppUsage appUsage = new AppUsage();
    try {
      // Define a time interval
      DateTime endDate = new DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

      // Fetch the usage stats
      Map<String, double> usage = await appUsage.fetchUsage(startDate, endDate);
      usage.removeWhere((key,val) => val == 0);

      setState(() {
        _appUsage = usage;
        _installedApps = _installedApps.where((app) => _appUsage.keys.toList().contains(app.packageName)).toList();
      });
    }
    on AppUsageException catch (exception) {
      print(exception);
    }

    /*Workmanager.initialize(
        backgroundFetch, // The top level function
        //isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    Workmanager.registerPeriodicTask("1", "fetchBackgroundData", frequency: Duration(minutes: 15));*/
  }

  @override
  void initState(){
    super.initState();
    setup();
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: _installedApps.length == 0 || _appUsage == null ? loader : Padding(
        padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        child: ListView.builder(
          itemCount: _installedApps.length,
          itemBuilder: (context, index){
            return Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Image.memory(_installedApps[index].icon, scale: 8,)
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      flex: 8,
                      child: Text('${_installedApps[index].appName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('${formatTime(_appUsage[_installedApps[index].packageName])}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
