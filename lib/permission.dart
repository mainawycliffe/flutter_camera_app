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
    var permision =
        Platform.isAndroid ? PermissionGroup.storage : PermissionGroup.photos;

    return _requestPermission(permision);
  }

  /// Check if the has permision to save photos to user gallery
  /// For Android, ExternalStorage, For iOS, Photos
  Future<bool> hasGalleryWritePermission() async {
    var permision =
        Platform.isAndroid ? PermissionGroup.storage : PermissionGroup.photos;

    return hasPermission(permision);
  }

  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
        await _permissionHandler.checkPermissionStatus(permission);

    return permissionStatus == PermissionStatus.granted;
  }
}
