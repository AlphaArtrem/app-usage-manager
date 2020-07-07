package com.alphaartrem.appusagemanager;

import android.app.NotificationManager;
import android.app.Service;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

public class BackgroundService extends BroadcastReceiver {
    private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

    @Override
    public void onReceive(Context arg0, Intent arg1) {
        showNotification();

    }

    private void showNotification(){
        Calendar start = Calendar.getInstance();
        start.set(Calendar.HOUR, 0);
        start.set(Calendar.MINUTE, 0);
        start.set(Calendar.SECOND, 0);
        long end = System.currentTimeMillis();

        Context context = this.getApplicationContext();
        UsageStatsManager manager = (UsageStatsManager) context.getSystemService(Context.USAGE_STATS_SERVICE);
        Map<String, UsageStats> usageStatsMap = manager.queryAndAggregateUsageStats(start.getTimeInMillis(), end);
        SharedPreferences prefs;
        Map<String, ?> trackedApps;
        String overusedApps = "";
        try {
            prefs = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            trackedApps = prefs.getAll();
        }
        catch (Exception e){
            prefs = null;
            trackedApps = null;
        }

        PackageManager packageManager = getApplicationContext().getPackageManager();
        ApplicationInfo applicationInfo;

        if(trackedApps != null){
            List<String> trackedPackagesNames = new ArrayList<>(trackedApps.keySet());
            for(int i = 0; i < trackedPackagesNames.size(); i++){
                String currentPackage = trackedPackagesNames.get(i).substring(8);
                if(usageStatsMap.containsKey(currentPackage)){
                    int usedTime = (int)(usageStatsMap.get(currentPackage).getTotalTimeInForeground() / 1000);
                    int allocatedTime = Integer.parseInt(trackedApps.get(trackedPackagesNames.get(i)).toString());
                    if(usedTime > allocatedTime){
                        try {
                            applicationInfo = packageManager.getApplicationInfo( currentPackage, 0);
                            String appName = (String) (applicationInfo != null ? packageManager.getApplicationLabel(applicationInfo) : "(unknown)");
                            overusedApps = "Overused " + appName + " By " + formatTime(usedTime - allocatedTime) +'\n';
                        } catch (final PackageManager.NameNotFoundException e) {}
                    }
                }
            }
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"messages")
                .setContentTitle("You Have Overused Some App(s)")
                .setSmallIcon(R.drawable.app_icon)
                .setStyle(new NotificationCompat.BigTextStyle()
                        .bigText(overusedApps));

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