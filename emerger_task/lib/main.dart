import 'dart:convert';
import 'dart:io';

import 'package:emerger_task/data/database.dart';
import 'package:emerger_task/environement/environment.dart';
import 'package:emerger_task/models/photo_model.dart';
import 'package:emerger_task/widgets/generic_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'logic/bloc/network_bloc.dart';
import 'logic/bloc/network_event.dart';
import 'logic/bloc/network_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => NetworkBloc()..add(NetworkObserve()),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  bool? isConnected;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<PhotoModel>> photoModel;
  final DatabaseManager databaseManager = DatabaseManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergere Tech Task'),
      ),
      body: Center(
        child: FutureBuilder(
            future: isInternetConnectedorNot(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return BlocBuilder<NetworkBloc, NetworkState>(
                  builder: (context, state) {
                    if (state is NetworkSuccess || (snapshot.data == true)) {
                      print('Fetching from internet!!');
                      return GenericWidget(
                        key: const ObjectKey('online_mode'),
                        databaseManager: databaseManager,
                        futurePhotoModel: _fetchAndSavedataInLocal(),
                      );
                    } else if (state is NetworkFailure ||
                        (snapshot.data == false)) {
                      return FutureBuilder(
                          future: tableIsEmpty(),
                          builder: (context, tableEmptySnapshot) {
                            if (tableEmptySnapshot.connectionState ==
                                    ConnectionState.done &&
                                tableEmptySnapshot.data == false) {
                              print('Fetching from local!!');
                              return GenericWidget(
                                key: const ObjectKey('Offline_mode'),
                                databaseManager: databaseManager,
                                futurePhotoModel: databaseManager.getDataList(),
                              );
                            } else if (tableEmptySnapshot.connectionState ==
                                    ConnectionState.done &&
                                tableEmptySnapshot.data == true) {
                              return const Text(
                                  'Switch on the internet for first time');
                            } else {
                              return const CircularProgressIndicator();
                            }
                          });
                    }
                    return const CircularProgressIndicator();
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<PhotoModel>> _fetchAndSavedataInLocal() async {
    final response = await http.get(Uri.parse(Environment().backendUrl));

    if (response.statusCode == 200) {
      int? id = await databaseManager.insertData(
          (jsonDecode(response.body) as List)
              .map((data) => PhotoModel.fromJson(data))
              .toList());
      print(id);
      return (jsonDecode(response.body) as List)
          .map((data) => PhotoModel.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<bool?> isInternetConnectedorNot() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        widget.isConnected = true;
        return widget.isConnected;
      }
    } on SocketException catch (_) {
      widget.isConnected = false;
      print('not connected');
      return widget.isConnected;
    }
  }

  Future<bool?> tableIsEmpty() async {
    var db = await databaseManager.openDb();

    int? count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM photo'));

    print(count);
    return count != null && count > 0 ? false : true;
  }
}
