import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) return true;
      if (await Permission.manageExternalStorage.request().isGranted) return true;
      return false;
    } else if (Platform.isIOS) {
      return await Permission.storage.request().isGranted;
    }
    return true;
  }

  Future<String> getDownloadPath() async {
    if (Platform.isAndroid) {
      // Use standard public downloads directory on Android if possible,
      // fallback to app doc dir
         return '/storage/emulated/0/Download';
    } 
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String?> downloadStream(
    String url, 
    String fileName, 
    Function(double) onProgress
  ) async {
    if (!await checkPermissions()) {
      throw Exception('Storage permission denied');
    }

    final path = await getDownloadPath();
    final fullPath = '$path/$fileName';

    try {
      await _dio.download(
        url,
        fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      return fullPath;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }
}
