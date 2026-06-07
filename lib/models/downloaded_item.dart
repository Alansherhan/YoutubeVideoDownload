import 'package:equatable/equatable.dart';

class DownloadedItem extends Equatable {
  final String title;
  final String filePath;
  final String formatType;
  final int timestamp;
  final String thumbnail;

  const DownloadedItem({
    required this.title,
    required this.filePath,
    required this.formatType,
    required this.timestamp,
    required this.thumbnail,
  });

  factory DownloadedItem.fromJson(Map<String, dynamic> json) {
    return DownloadedItem(
      title: json['title'],
      filePath: json['filePath'],
      formatType: json['formatType'],
      timestamp: json['timestamp'],
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'filePath': filePath,
      'formatType': formatType,
      'timestamp': timestamp,
      'thumbnail': thumbnail,
    };
  }

  @override
  List<Object?> get props => [title, filePath, formatType, timestamp, thumbnail];
}
