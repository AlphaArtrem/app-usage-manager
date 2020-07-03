package com.alphaartrem.appusagemanager;

import android.app.NotificationManager;
import android.app.Service;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.util.Calendar;
import java.util.List;
import java.util.Map;

public class MyService extends Service {

    @Override
    public void onCreate() {
        super.onCreate();

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            Calendar start = Calendar.getInstance();
            start.set(Calendar.HOUR, 0);
            start.set(Calendar.MINUTE, 0);
            start.set(Calendar.SECOND, 0);
            long end = System.currentTimeMillis();

            Context context = this.getApplicationContext();
            UsageStatsManager mUsageStatsManager = (UsageStatsManager) context.getSystemService(Context.USAGE_STATS_SERVICE);
            List<UsageStats> lUsageStatsList = mUsageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start.getTimeInMillis(), end);

            String text= "This is running in Background" + lUsageStatsList.get(0).getPackageName() + " : " + lUsageStatsList.get(0).getTotalTimeInForeground();
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"messages")
                    .setContentText(text)
                    .setContentTitle("Flutter Background")
                    .setSmallIcon(R.drawable.app_icon);

            startForeground(101,builder.build());
        }

    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}