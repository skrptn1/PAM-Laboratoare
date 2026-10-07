import 'dart:convert';
import 'dart:io';

import 'package:gemstore/data/store_repository.dart';
import 'package:gemstore/models/store_data.dart';

Map<String, dynamic> storeJson() =>
    jsonDecode(File('assets/data/lab_v1.json').readAsStringSync())
        as Map<String, dynamic>;
StoreData fixtureStore() => StoreData.fromJson(storeJson());

class FixtureRepository extends StoreRepository {
  final StoreData data;
  FixtureRepository(this.data);
  @override
  Future<StoreData> load() async => data;
}
