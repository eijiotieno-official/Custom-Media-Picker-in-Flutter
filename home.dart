import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tutorial_flutter/media_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<AssetEntity> selectedAssetList = [];

  Future pickAssets({
    required int maxCount,
    required RequestType requestType,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MediaPicker(maxCount, requestType);
        },
      ),
    );
    if (result.isNotEmpty || result != null) {
      setState(() {
        selectedAssetList = result;
      });
    }
  }

  List<File> selectedFiles = [];

  Future convertAssetsToFiles(List<AssetEntity> assetEntities) async {
    for (var i = 0; i < assetEntities.length; i++) {
      final File? file = await assetEntities[i].originFile;
      setState(() {
        selectedFiles.add(file!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: selectedAssetList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            AssetEntity assetEntity = selectedAssetList[index];
            return Padding(
              padding: const EdgeInsets.all(2),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AssetEntityImage(
                      assetEntity,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(1000),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                  if (assetEntity.type == AssetType.video)
                    const Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Iconsax.video5,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            pickAssets(
              maxCount: 10,
              requestType: RequestType.video,
            );
          },
          child: const Icon(Iconsax.image5),
        ),
      ),
    );
  }
}
