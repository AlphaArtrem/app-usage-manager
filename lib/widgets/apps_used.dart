import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:appusagemanager/common/functions.dart';
import 'package:appusagemanager/screens/home.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppsUsedToday extends StatefulWidget {
  @override
  _AppsUsedTodayState createState() => _AppsUsedTodayState();
}

class _AppsUsedTodayState extends State<AppsUsedToday> {
  List _installedApps = [];
  Map<String, double> _appUsage;

  void setup() async{
    await notificationSetup();

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

  Future notificationSetup() async {
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
    await flutterLocalNotificationsPlugin.show(
      0,
      'Overused X App',
      'You have exceeded the usage of App X by Y time',
      platformChannelSpecifics,
    );
  }

  Future selectNotification(String payload) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home(),),
              );
            },
          )
        ],
      ),
    );
  }
}
