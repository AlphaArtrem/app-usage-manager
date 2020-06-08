import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/classes/database.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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
      _appUsage = usage;
      _unTrackedApps = _unTrackedApps.where((app) => _appUsage.keys.toList().contains(app.packageName)).toList();
    }
    on AppUsageException catch (exception) {
      print(exception);
    }
    
    List<Map<String, dynamic>> trackedApps = await _database.getAllRows();
    List<String> trackedAppsPackages = [];

    for(int i = 0 ; i < trackedApps.length; i++){
      trackedAppsPackages.add(trackedApps[i][TrackedAppsDatabase.columnPackage]);
    }
    
    setState(() {
      _unTrackedApps = _unTrackedApps.where((app) => !trackedAppsPackages.contains(app.packageName.toString())).toList();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: Color.fromRGBO(255, 0, 255, 0.3),
                  blurRadius: 2,
                  offset: Offset(0, 0),
                )],
              ),
              child: Container(
                padding: EdgeInsets.all(6.5),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled : true,
                          border: InputBorder.none,
                          hintText: "Search By App",
                        ),
                        onChanged: (val){
                          if(_unTrackedAppsVisible.isNotEmpty){
                            setState(() {
                              _unTrackedAppsVisible = _unTrackedApps..removeWhere((app) => !app.appName.toString().toLowerCase().startsWith(val.toLowerCase()));
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _unTrackedAppsVisible.length == 0 ? Center(child: loader,) : ListView.builder(
                itemCount: _unTrackedAppsVisible.length,
                itemBuilder: (context, index){
                  return Card(
                    elevation: 1,
                    child: ListTile(
                      onTap: (){
                        int maxTime;
                        dynamic result;
                        DatePicker.showTimePicker(
                          context,
                          theme: DatePickerTheme(
                            doneStyle: TextStyle(color: Colors.purpleAccent),
                            containerHeight: MediaQuery.of(context).size.height * 0.9,
                          ),
                          showTitleActions: true,
                          onConfirm: (time) async{
                            maxTime = (time.hour * 60 * 60) + (time.minute * 60);
                            result = await _database.addEntry({
                              TrackedAppsDatabase.columnTime : maxTime,
                              TrackedAppsDatabase.columnPackage : _unTrackedAppsVisible[index].packageName,
                            });
                            if(result != null){
                              setState(() {
                                _unTrackedApps.removeWhere((app) => app.packageName ==  _unTrackedAppsVisible[index].packageName);
                                _unTrackedAppsVisible.removeWhere((app) => app.packageName ==  _unTrackedAppsVisible[index].packageName);
                              });
                            }
                          },
                          currentTime: DateTime.now(),
                          locale: LocaleType.en,
                        );
                      },
                      title: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Image.memory(_unTrackedAppsVisible[index].icon, scale: 8,),
                          ),
                          Expanded(
                            flex: 9,
                              child: Text('${_unTrackedAppsVisible[index].appName.toString()}',)
                          ),
                          Icon(Icons.navigate_next, color: Colors.blueGrey,)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),],
        ),
      ),
    );
  }
}
