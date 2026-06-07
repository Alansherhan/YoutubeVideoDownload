import 'package:equatable/equatable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/downloaded_item.dart';

abstract class DownloaderEvent extends Equatable {
  const DownloaderEvent();

  @override
  List<Object> get props => [];
}

class FetchMetadataEvent extends DownloaderEvent {
  final String url;
  const FetchMetadataEvent(this.url);

  @override
  List<Object> get props => [url];
}

class StartDownloadEvent extends DownloaderEvent {
  final Video video;
  final StreamInfo streamInfo;
  final String formatType;
  
  const StartDownloadEvent(this.video, this.streamInfo, this.formatType);

  @override
  List<Object> get props => [video, streamInfo, formatType];
}

class LoadLibraryEvent extends DownloaderEvent {}

class DeleteItemEvent extends DownloaderEvent {
  final DownloadedItem item;
  const DeleteItemEvent(this.item);

  @override
  List<Object> get props => [item];
}
