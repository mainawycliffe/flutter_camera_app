import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<bool> _requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);

    if (result[permission] != PermissionStatus.granted) {
      return false;
    }

    return true;
  }

  /// Requests the user permission to save photos and videos to the Gallery
  /// For Android, ExternalStorage, For iOS, Photos
  Future<bool> requestPermissionToGallery() async {
    var permission =
        Platform.isAndroid ? PermissionGroup.storage : PermissionGroup.photos;

    return _requestPermission(permission);
  }

  /// Check if the has permission to save photos to user gallery
  /// For Android, ExternalStorage, For iOS, Photos
  Future<bool> hasGalleryWritePermission() async {
    var permission =
        Platform.isAndroid ? PermissionGroup.storage : PermissionGroup.photos;

    return hasPermission(permission);
  }

  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
        await _permissionHandler.checkPermissionStatus(permission);

    return permissionStatus == PermissionStatus.disabled;
  }
}
