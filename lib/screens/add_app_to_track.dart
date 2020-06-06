import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/classes/database.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class AddAppToTrack extends StatefulWidget {
  @override
  _AddAppToTrackState createState() => _AddAppToTrackState();
}

class _AddAppToTrackState extends State<AddAppToTrack> {
  List _unTrackedApps = [];
  List _unTrackedAppsVisible = [];
  Map<String, double> _appUsage;
  final _database = TrackedAppsDatabase.instance;

  void setup() async{
    await DeviceApps.getInstalledApplications(onlyAppsWithLaunchIntent: true, includeAppIcons: true).then((apps) {
      setState(() {
        _unTrackedApps = apps;
      });
    });

    AppUsage appUsage = new AppUsage();
    try {
      // Define a time interval
      DateTime endDate = new DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

      // Fetch the usage stats
      Map<String, double> usage = await appUsage.fetchUsage(startDate, endDate);

      setState(() {
        _appUsage = usage;
        _unTrackedApps = _unTrackedApps.where((app) => _appUsage.keys.toList().contains(app.packageName)).toList();
      });
    }
    on AppUsageException catch (exception) {
      print(exception);
    }

    setState(() {
      _unTrackedAppsVisible = _unTrackedApps;
    });

  }

  @override
  void initState(){
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
        child: Expanded(
          child: _unTrackedAppsVisible.length == 0 ? Center(child: loader,) : ListView.builder(
            itemCount: _unTrackedAppsVisible.length,
            itemBuilder: (context, index){
              return Card(
                elevation: 1,
                child: Container(
                  padding: EdgeInsets.all(6.5),
                  child: ListTile(
                    onTap: () {
                    },
                    title: Row(
                      children: <Widget>[
                        Expanded(child: Text('${_unTrackedAppsVisible[index].appName.toString()}',)),
                        Icon(Icons.navigate_next, color: Colors.blueGrey,)
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
