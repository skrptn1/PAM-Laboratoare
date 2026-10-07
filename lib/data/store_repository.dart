import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/store_data.dart';

Map<String, dynamic> _decodeStore(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

typedef AssetReader = Future<String> Function(String path);

class StoreRepository {
  final AssetReader readAsset;
  StoreRepository({AssetReader? readAsset})
    : readAsset = readAsset ?? rootBundle.loadString;

  Future<StoreData> load() async {
    final source = await readAsset('assets/data/lab_v1.json');
    final json = await compute(_decodeStore, source);
    return StoreData.fromJson(json);
  }
}
