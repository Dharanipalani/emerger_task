import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/photo_model.dart';

class GenericWidget extends StatelessWidget {
  const GenericWidget({
    Key? key,
    required this.databaseManager,
    required this.futurePhotoModel,
  }) : super(key: key);

  final DatabaseManager databaseManager;
  final Future<List<PhotoModel>> futurePhotoModel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PhotoModel>>(
      future: futurePhotoModel,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.blueGrey,
                    height: 100,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.0),
                            child: CachedNetworkImage(
                                imageUrl: snapshot.data![index].thumbnailUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.fitWidth),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            snapshot.data![index].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            child: CachedNetworkImage(
                                imageUrl: snapshot.data![index].url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.fitHeight),
                          ),
                        )
                      ],
                    ));
              });
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
