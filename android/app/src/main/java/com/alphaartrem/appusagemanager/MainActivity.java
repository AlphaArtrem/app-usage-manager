package com.alphaartrem.appusagemanager;

import io.flutter.embedding.android.FlutterActivity;

import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    private void showNotification(){
        Calendar start = Calendar.getInstance();
        start.set(Calendar.HOUR, 0);
        start.set(Calendar.MINUTE, 0);
        start.set(Calendar.SECOND, 0);
        long end = System.currentTimeMillis();

        Context context = this.getApplicationContext();
        UsageStatsManager mUsageStatsManager = (UsageStatsManager) context.getSystemService(Context.USAGE_STATS_SERVICE);
        List<UsageStats> lUsageStatsList = mUsageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start.getTimeInMillis(), end);
        SharedPreferences prefs;
        Map<String, ?> trackedApps;
        String a = "Stack - ";
        Map<String, Long> appUsageDetails = Collections.emptyMap();
        try {
            prefs = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            trackedApps = prefs.getAll();
        }
        catch (Exception e){
            prefs = null;
            trackedApps = null;
        }

        for(int i = 0 ; i < lUsageStatsList.size(); i++){
            appUsageDetails.put(lUsageStatsList.get(i).getPackageName(), lUsageStatsList.get(i).getTotalTimeInForeground());
            a += 'a';
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"messages")
                .setContentTitle("You Have Overused Some App(s)")
                .setSmallIcon(R.drawable.app_icon)
                .setStyle(new NotificationCompat.BigTextStyle()
                        .bigText(a + '\n' + appUsageDetails));

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);

        // notificationId is a unique int for each notification that you must define
        notificationManager.notify(101, builder.build());
    }
}