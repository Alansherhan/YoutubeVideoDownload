import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/downloaded_item.dart';

class StorageService {
  static const String _libraryKey = 'downloads_library';

  Future<List<DownloadedItem>> getLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_libraryKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => DownloadedItem.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveToLibrary(DownloadedItem item) async {
    final library = await getLibrary();
    library.insert(0, item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_libraryKey, jsonEncode(library.map((e) => e.toJson()).toList()));
  }

  Future<void> removeFromLibrary(DownloadedItem item) async {
    final library = await getLibrary();
    library.removeWhere((e) => e.filePath == item.filePath);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_libraryKey, jsonEncode(library.map((e) => e.toJson()).toList()));
  }
}
