package com.alphaartrem.appusagemanager;

import io.flutter.embedding.android.FlutterActivity;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    private PendingIntent pendingIntent;
    private AlarmManager manager;

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);

        Intent alarmIntent = new Intent(this, BackgroundService.class);
        pendingIntent = PendingIntent.getBroadcast(this, 0, alarmIntent, 0);
        startAlarm();
    }

    public void startAlarm() {
        manager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        int interval = 100000;

        manager.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), interval, pendingIntent);
    }
}