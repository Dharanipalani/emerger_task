import 'dart:convert';

import 'package:emerger_task/data/database.dart';
import 'package:emerger_task/environement/environment.dart';
import 'package:emerger_task/models/photo_model.dart';
import 'package:emerger_task/widgets/generic_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

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
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<PhotoModel>> photoModel;
  final DatabaseManager databaseManager = DatabaseManager();

  @override
  void initState() {
    super.initState();
    photoModel = _fetchAndSavedataInLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergere Tech Task'),
      ),
      body: Center(
        child: BlocBuilder<NetworkBloc, NetworkState>(
          builder: (context, state) {
            if (state is NetworkSuccess) {
              print('Fetching from internet!!');
              return GenericWidget(
                key: const ObjectKey('online_mode'),
                databaseManager: databaseManager,
                futurePhotoModel: photoModel,
              );
            } else if (state is NetworkFailure) {
              print('Fetching from local!!');
              return GenericWidget(
                key: const ObjectKey('Offline_mode'),
                databaseManager: databaseManager,
                futurePhotoModel: databaseManager.getDataList(),
              );
            }

            return const CircularProgressIndicator();
          },
        ),
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
}
