package com.alphaartrem.appusagemanager;

import io.flutter.embedding.android.FlutterActivity;

import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";
    private static final String CHANNEL = "com.alphaartrem.appusagemanager/notification";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("showNotification")) {
                                try{
                                    showNotification();
                                    result.success("Notification Shown");
                                }
                                catch (Exception e){
                                    result.error("UNAVAILABLE", e.toString() , null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
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
        String overusedApps = "";
        Map<String, Long> appUsageDetails = new HashMap<>();
        try {
            prefs = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            trackedApps = prefs.getAll();
        }
        catch (Exception e){
            prefs = null;
            trackedApps = null;
        }

        final PackageManager packageManager = getApplicationContext().getPackageManager();
        ApplicationInfo applicationInfo;

        for(int i = 0 ; i < lUsageStatsList.size(); i++){
            appUsageDetails.put(lUsageStatsList.get(i).getPackageName(), (lUsageStatsList.get(i).getTotalTimeInForeground() / 1000));
        }

        if(trackedApps != null){
            List<String> trackedPackagesNames = new ArrayList<>(trackedApps.keySet());
            for(int i = 0; i < trackedPackagesNames.size(); i++){
                String currentPackage = trackedPackagesNames.get(i).substring(8);
                if(appUsageDetails.containsKey(currentPackage)){
                    int usedTime = appUsageDetails.get(currentPackage).intValue();
                    int allocatedTime = prefs.getInt(currentPackage, 0);
                    if(usedTime > allocatedTime){
                        try {
                            applicationInfo = packageManager.getApplicationInfo( currentPackage, 0);
                            final String appName = (String) (applicationInfo != null ? packageManager.getApplicationLabel(applicationInfo) : "(unknown)");
                            overusedApps = "Overused " + appName + " By " + formatTime(usedTime - allocatedTime) +'\n';
                        } catch (final PackageManager.NameNotFoundException e) {
                        }
                    }
                }
            }
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"messages")
                .setContentTitle("You Have Overused Some App(s)")
                .setSmallIcon(R.drawable.app_icon)
                .setStyle(new NotificationCompat.BigTextStyle()
                        .bigText(overusedApps);

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);

        // notificationId is a unique int for each notification that you must define
        notificationManager.notify(101, builder.build());
    }

    private String formatTime(int seconds){
        int buffer = seconds / (60 * 60);
        seconds = seconds % (60 * 60);
        String time = Integer.toString(buffer).length() == 1 ? '0' + Integer.toString(buffer) + ':' : Integer.toString(buffer) + ':';
        buffer = seconds / 60;
        seconds = seconds % 60;
        time += Integer.toString(buffer).length() == 1 ? '0' + Integer.toString(buffer) + ':' : Integer.toString(buffer) + ':';
        buffer = seconds;
        time += Integer.toString(buffer).length() == 1 ? '0' + Integer.toString(buffer) : Integer.toString(buffer);

        return time;
    }
}