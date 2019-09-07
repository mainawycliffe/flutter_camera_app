import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<bool> _requestPermission(List<PermissionGroup> permissions) async {
    var result = await _permissionHandler.requestPermissions(permissions);
    for (var permission in permissions) {
      if (result[permission] != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  /// Requests the users permission to read their contacts.
  Future<bool> requestPhotosPermission() async {
    return _requestPermission([
      PermissionGroup.storage,
      PermissionGroup.photos,
      PermissionGroup.mediaLibrary
    ]);
  }

  Future<bool> hasPhotosPermission() async {
    return hasPermission(PermissionGroup.storage);
  }

  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
        await _permissionHandler.checkPermissionStatus(permission);
    return permissionStatus == PermissionStatus.granted;
  }
}
