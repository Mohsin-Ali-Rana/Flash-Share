import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appsProvider = FutureProvider<List<Application>>((ref) async {
  // Fetch installed apps with icons and paths
  // CRITICAL: On Android 11+, this requires <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
  // in AndroidManifest.xml
  final apps = await DeviceApps.getInstalledApplications(
    includeAppIcons: true,
    includeSystemApps: false, // Set to true if you want to share System apps too
    onlyAppsWithLaunchIntent: true,
  );

  // Sort alphabetically for a professional list
  apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

  return apps;
});

// Helper to convert Application to File
File getApkFile(ApplicationWithIcon app) {
  return File(app.apkFilePath);
}