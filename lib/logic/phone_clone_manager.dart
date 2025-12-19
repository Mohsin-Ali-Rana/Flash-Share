import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

// State to hold the scan results
class CloneData {
  List<File> photos = [];
  List<File> videos = [];
  List<File> apps = [];
  List<Contact> contacts = [];
  bool isLoading = true;
}

final cloneProvider = StateNotifierProvider.autoDispose<CloneNotifier, CloneData>((ref) {
  return CloneNotifier();
});

class CloneNotifier extends StateNotifier<CloneData> {
  CloneNotifier() : super(CloneData()) {
    _scanPhone();
  }

  Future<void> _scanPhone() async {
    final data = CloneData();

    // 1. Scan Photos & Videos
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.common);
      if (albums.isNotEmpty) {
        final List<AssetEntity> media = await albums[0].getAssetListRange(start: 0, end: 5000); // Limit scan for speed
        for (var asset in media) {
          final file = await asset.file;
          if (file != null) {
            if (asset.type == AssetType.image) data.photos.add(file);
            if (asset.type == AssetType.video) data.videos.add(file);
          }
        }
      }
    }

    // 2. Scan Apps
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      onlyAppsWithLaunchIntent: true,
    );
    for (var app in apps) {
      if (app is ApplicationWithIcon) {
        data.apps.add(File(app.apkFilePath));
      }
    }

    // 3. Scan Contacts
    if (await FlutterContacts.requestPermission()) {
      data.contacts = await FlutterContacts.getContacts(withProperties: true);
    }

    data.isLoading = false;
    state = data;
  }

  // Export selected items to a list of Files for the Server
  Future<List<File>> prepareTransfer({
    bool includePhotos = false,
    bool includeVideos = false,
    bool includeApps = false,
    bool includeContacts = false,
  }) async {
    List<File> transferList = [];

    if (includePhotos) transferList.addAll(state.photos);
    if (includeVideos) transferList.addAll(state.videos);
    if (includeApps) transferList.addAll(state.apps);

    if (includeContacts && state.contacts.isNotEmpty) {
      // Generate VCF File
      final directory = await getTemporaryDirectory();
      final vcfFile = File('${directory.path}/Contacts_Backup.vcf');
      String vcfContent = "";
      for (var c in state.contacts) {
        vcfContent += "BEGIN:VCARD\nVERSION:3.0\nFN:${c.displayName}\nTEL:${c.phones.isNotEmpty ? c.phones.first.number : ''}\nEND:VCARD\n";
      }
      await vcfFile.writeAsString(vcfContent);
      transferList.add(vcfFile);
    }

    return transferList;
  }
}