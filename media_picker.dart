import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tutorial_flutter/media_services.dart';

class MediaPicker extends StatefulWidget {
  final int maxCount;
  final RequestType requestType;
  const MediaPicker(this.maxCount, this.requestType, {super.key});

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];

  @override
  void initState() {
    MediaServices().loadAlbums(widget.requestType).then(
      (value) {
        setState(() {
          albumList = value;
          selectedAlbum = value[0];
        });
        //LOAD RECENT ASSETS
        MediaServices().loadAssets(selectedAlbum!).then(
          (value) {
            setState(() {
              assetList = value;
            });
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: DropdownButton<AssetPathEntity>(
            value: selectedAlbum,
            onChanged: (AssetPathEntity? value) {
              setState(() {
                selectedAlbum = value;
              });
              MediaServices().loadAssets(selectedAlbum!).then(
                (value) {
                  setState(() {
                    assetList = value;
                  });
                },
              );
            },
            items: albumList.map<DropdownMenuItem<AssetPathEntity>>(
                (AssetPathEntity album) {
              return DropdownMenuItem<AssetPathEntity>(
                value: album,
                // ignore: deprecated_member_use
                child: Text("${album.name} (${album.assetCount})"),
              );
            }).toList(),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context, selectedAssetList);
              },
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: assetList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: assetList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  AssetEntity assetEntity = assetList[index];
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: assetWidget(assetEntity),
                  );
                },
              ),
      ),
    );
  }

  Widget assetWidget(AssetEntity assetEntity) => Stack(
    children: [
      Positioned.fill(
        child: Padding(
         padding: EdgeInsets.all(
                  selectedAssetList.contains(assetEntity) == true ? 15 : 0),
          child: AssetEntityImage(
            assetEntity,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(250),
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
      Positioned.fill(
        child: Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () {
              selectAsset(assetEntity: assetEntity);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedAssetList.contains(assetEntity) == true
                      ? Colors.blue
                      : Colors.black12,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "${selectedAssetList.indexOf(assetEntity) + 1}",
                    style: TextStyle(
                      color:
                          selectedAssetList.contains(assetEntity) == true
                              ? Colors.white
                              : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  void selectAsset({
    required AssetEntity assetEntity,
  }) {
    if (selectedAssetList.contains(assetEntity)) {
      setState(() {
        selectedAssetList.remove(assetEntity);
      });
    } else if (selectedAssetList.length < widget.maxCount) {
      setState(() {
        selectedAssetList.add(assetEntity);
      });
    }
  }
}
