import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class MediaServices {
  Future loadAlbums(RequestType requestType) async {
    var permission = await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];

    if (permission.isAuth == true) {
      albumList = await PhotoManager.getAssetPathList(
        type: requestType,
      );
    } else {
      PhotoManager.openSetting();
    }

    return albumList;
  }

  Future loadAssets(AssetPathEntity selectedAlbum) async {
    List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(
      start: 0,
      // ignore: deprecated_member_use
      end: selectedAlbum.assetCount,
    );
    return assetList;
  }
}
