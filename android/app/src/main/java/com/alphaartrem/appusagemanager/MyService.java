package com.alphaartrem.appusagemanager;

import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

public class MyService extends Service {

    @Override
    public void onCreate() {
        super.onCreate();

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            String text= "This is running in Background";
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