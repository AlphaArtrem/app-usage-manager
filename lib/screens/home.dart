import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _installedApps = [];
  Map<String, double> _appUsage;

  void setup() async{
    await DeviceApps.getInstalledApplications(onlyAppsWithLaunchIntent: true, includeAppIcons: true).then((apps) {
      setState(() {
        _installedApps = apps;
        print(_installedApps);
      });
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Apps Used Today"),
        centerTitle: true,
      ),
      body: Center(
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
      ),
    );
  }

  String formatTime(double seconds){
    int buffer = seconds ~/ (60 * 60);
    seconds = seconds % (60 * 60);
    String time = buffer.toString().length == 1 ? '0' + buffer.toString() + ':' : buffer.toString() + ':';
    buffer = seconds ~/ (60);
    seconds = seconds % (60);
    time += buffer.toString().length == 1 ? '0' + buffer.toString() + ':' : buffer.toString() + ':';
    buffer = seconds.toInt();
    time += buffer.toString().length == 1 ? '0' + buffer.toString() : buffer.toString();

    return time;
  }
}
