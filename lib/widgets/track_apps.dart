import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/classes/database.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:appusagemanager/common/functions.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class TrackApps extends StatefulWidget {
  @override
  _TrackAppsState createState() => _TrackAppsState();
}

class _TrackAppsState extends State<TrackApps> {
  final _database = TrackedAppsDatabase.instance;
  int _rowCount;
  List<Map<String, dynamic>> _trackedAppsData;
  Map<String, double> _trackedAppsTime = {};
  List _trackedApps = [];
  Map<String, double> _appUsage;

  void setup() async{
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

    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _rowCount == null ? loader : Padding(
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: _rowCount == 0 ? Text("You are not tracking any app usage.") : ListView.builder(
            itemCount: _trackedApps.length,
            itemBuilder: (context, index){
              return Card(
                elevation: 1,
                child: ListTile(
                  onTap: (){},
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Image.memory(_trackedApps[index].icon, scale: 8,),
                      ),
                      Expanded(
                          flex: 8,
                          child: Text('${_trackedApps[index].appName.toString()}',)
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${formatTime(_appUsage[_trackedApps[index].packageName])}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: _trackedAppsTime[_trackedApps[index].packageName] >= _appUsage[_trackedApps[index].packageName] ? Colors.green : Colors.red,
                          ),
                        ),
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
