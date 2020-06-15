package com.alphaartrem.appusagemanager;

import io.flutter.embedding.android.FlutterActivity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private Intent forService;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try{
            GeneratedPluginRegistrant.registerWith(this.getFlutterEngine());
        }
        catch (Exception e){

        }

        forService = new Intent(MainActivity.this,MyService.class);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(forService);
        } else {
            startService(forService);
        }

    }
}