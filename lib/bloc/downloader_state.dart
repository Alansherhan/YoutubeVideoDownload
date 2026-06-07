import 'package:equatable/equatable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/downloaded_item.dart';

abstract class DownloaderState extends Equatable {
  const DownloaderState();
  
  @override
  List<Object?> get props => [];
}

class DownloaderInitial extends DownloaderState {}

class FetchingMetadata extends DownloaderState {}

class MetadataFetched extends DownloaderState {
  final Video video;
  final StreamManifest manifest;

  const MetadataFetched(this.video, this.manifest);

  @override
  List<Object?> get props => [video, manifest];
}

class DownloaderError extends DownloaderState {
  final String message;
  const DownloaderError(this.message);

  @override
  List<Object?> get props => [message];
}

class DownloadingState extends DownloaderState {
  final double progress;
  final String currentItemTitle;

  const DownloadingState(this.progress, this.currentItemTitle);

  @override
  List<Object?> get props => [progress, currentItemTitle];
}

class DownloadComplete extends DownloaderState {
  final String filePath;
  const DownloadComplete(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class LibraryLoaded extends DownloaderState {
  final List<DownloadedItem> items;
  const LibraryLoaded(this.items);

  @override
  List<Object?> get props => [items];
}
