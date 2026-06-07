import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../bloc/downloader_bloc.dart';
import '../bloc/downloader_event.dart';
import '../bloc/downloader_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  void _fetchMetadata() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      context.read<DownloaderBloc>().add(FetchMetadataEvent(url));
    }
  }

  Future<void> _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _urlController.text = data!.text!;
      _fetchMetadata();
    }
  }

  void _showDownloadOptions(BuildContext context, Video video, StreamManifest manifest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final muxedStreams = manifest.muxed.sortByVideoQuality();
        final audioStreams = manifest.audioOnly.sortByBitrate();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Select Download Format',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Video (Muxed)', style: TextStyle(color: Colors.grey)),
            ...muxedStreams.map((s) => ListTile(
                  leading: const Icon(Icons.video_file, color: Colors.blue),
                  title: Text('${s.videoQuality.name} - ${s.container.name}'),
                  subtitle: Text('${s.size.totalMegaBytes.toStringAsFixed(2)} MB'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<DownloaderBloc>().add(
                          StartDownloadEvent(video, s, 'Video - ${s.videoQuality.name}'),
                        );
                  },
                )),
            const Divider(),
            const Text('Audio Only', style: TextStyle(color: Colors.grey)),
            ...audioStreams.map((s) => ListTile(
                  leading: const Icon(Icons.audio_file, color: Colors.red),
                  title: Text('${s.bitrate.kiloBitsPerSecond.toStringAsFixed(0)} kbps - ${s.container.name}'),
                  subtitle: Text('${s.size.totalMegaBytes.toStringAsFixed(2)} MB'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<DownloaderBloc>().add(
                          StartDownloadEvent(video, s, 'Audio - ${s.bitrate.kiloBitsPerSecond.round()}kbps'),
                        );
                  },
                )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YT Downloader', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<DownloaderBloc, DownloaderState>(
        listener: (context, state) {
          if (state is DownloaderError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is DownloadComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download completed successfully!'), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Paste YouTube URL here',
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Paste from clipboard',
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _fetchMetadata(),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: state is FetchingMetadata || state is DownloadingState ? null : _fetchMetadata,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Fetch Video', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: Builder(builder: (context) {
                      if (state is FetchingMetadata) {
                        return const CircularProgressIndicator();
                      } else if (state is MetadataFetched) {
                        return _buildVideoCard(state.video, state.manifest);
                      } else if (state is DownloadingState) {
                        return _buildProgressCard(state);
                      }
                      return const Text('Paste a link to get started', style: TextStyle(color: Colors.grey));
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(Video video, StreamManifest manifest) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(video.thumbnails.highResUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(video.author, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download Options'),
                    onPressed: () => _showDownloadOptions(context, video, manifest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressCard(DownloadingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_download, size: 50, color: Colors.blue),
            const SizedBox(height: 15),
            Text('Downloading...', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(state.currentItemTitle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Colors.grey[800],
              color: Colors.blue,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 10),
            Text('${(state.progress * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}
