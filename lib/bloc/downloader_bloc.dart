import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../services/download_service.dart';
import '../services/storage_service.dart';
import '../models/downloaded_item.dart';
import 'downloader_event.dart';
import 'downloader_state.dart';

class DownloaderBloc extends Bloc<DownloaderEvent, DownloaderState> {
  final YoutubeExplode _yt = YoutubeExplode();
  final DownloadService _downloadService = DownloadService();
  final StorageService _storageService = StorageService();

  DownloaderBloc() : super(DownloaderInitial()) {
    on<FetchMetadataEvent>(_onFetchMetadata);
    on<StartDownloadEvent>(_onStartDownload);
    on<LoadLibraryEvent>(_onLoadLibrary);
    on<DeleteItemEvent>(_onDeleteItem);
  }

  Future<void> _onFetchMetadata(FetchMetadataEvent event, Emitter<DownloaderState> emit) async {
    emit(FetchingMetadata());
    try {
      final video = await _yt.videos.get(event.url);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      emit(MetadataFetched(video, manifest));
    } catch (e) {
      emit(DownloaderError('Failed to fetch video: ${e.toString()}'));
    }
  }

  Future<void> _onStartDownload(StartDownloadEvent event, Emitter<DownloaderState> emit) async {
    try {
      emit(DownloadingState(0.0, event.video.title));
      
      final String safeTitle = event.video.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
      final ext = event.streamInfo.container.name;
      final fileName = '$safeTitle.$ext';

      final filePath = await _downloadService.downloadStream(
        event.streamInfo.url.toString(),
        fileName,
        (progress) {
          emit(DownloadingState(progress, event.video.title));
        },
      );

      if (filePath != null) {
        final item = DownloadedItem(
          title: event.video.title,
          filePath: filePath,
          formatType: event.formatType,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          thumbnail: event.video.thumbnails.mediumResUrl,
        );
        await _storageService.saveToLibrary(item);
        emit(DownloadComplete(filePath));
        // Reload Library
        add(LoadLibraryEvent());
      } else {
        emit(const DownloaderError('Download failed: Path is null'));
      }
    } catch (e) {
      emit(DownloaderError(e.toString()));
    }
  }

  Future<void> _onLoadLibrary(LoadLibraryEvent event, Emitter<DownloaderState> emit) async {
    try {
      final items = await _storageService.getLibrary();
      emit(LibraryLoaded(items));
    } catch (_) {
      // fail silently for library or handle
    }
  }

  Future<void> _onDeleteItem(DeleteItemEvent event, Emitter<DownloaderState> emit) async {
    await _storageService.removeFromLibrary(event.item);
    add(LoadLibraryEvent());
  }

  @override
  Future<void> close() {
    _yt.close();
    return super.close();
  }
}
