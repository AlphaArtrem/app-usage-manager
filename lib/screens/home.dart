import 'package:appusagemanager/common/formatting.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _installedApps = [];

  void setup() async{
    await DeviceApps.getInstalledApplications(onlyAppsWithLaunchIntent: true, includeAppIcons: true).then((apps) {
      setState(() {
        _installedApps = apps;
      });
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
      appBar: AppBar(
        title: Text("All App Usage"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: _installedApps.length == 0 ? loader : Padding(
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
                        flex: 9,
                        child: Text('${_installedApps[index].appName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),),
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
}
