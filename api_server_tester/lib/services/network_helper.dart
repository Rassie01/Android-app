// lib/services/network_helper.dart
import 'dart:io';

import 'package:http/http.dart' as http;
import 'database_helper.dart';

class NetworkHelper {
  static Future<bool> checkApi(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> pingServer(String ipAddress) async {
    try {
      final result = await InternetAddress.lookup(ipAddress);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> checkAllConnections() async {
    final data = await DatabaseHelper.instance.getAllItems();
    List<String> offlineItems = [];

    for (var item in data) {
      bool isOnline = item['type'] == 'server'
          ? await pingServer(item['url'])
          : await checkApi(item['url']);
      if (!isOnline) {
        offlineItems.add(item['name']);
      }
    }
    return offlineItems;
  }
}