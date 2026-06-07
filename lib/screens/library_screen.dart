import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import '../bloc/downloader_bloc.dart';
import '../bloc/downloader_event.dart';
import '../bloc/downloader_state.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  void _openFile(String path, BuildContext context) {
    if (File(path).existsSync()) {
      OpenFile.open(path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found. It might have been moved or deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-fetch library on build to ensure it's up to date
    context.read<DownloaderBloc>().add(LoadLibraryEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads Library'),
      ),
      body: BlocBuilder<DownloaderBloc, DownloaderState>(
        buildWhen: (previous, current) => current is LibraryLoaded,
        builder: (context, state) {
          if (state is LibraryLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text('No downloads yet', style: TextStyle(color: Colors.grey)),
              );
            }

            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Dismissible(
                  key: Key(item.filePath),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<DownloaderBloc>().add(DeleteItemEvent(item));
                    try {
                      final file = File(item.filePath);
                      if (file.existsSync()) {
                        file.deleteSync();
                      }
                    } catch (e) {
                      debugPrint('Could not delete file off disk: $e');
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: item.thumbnail.isNotEmpty
                            ? Image.network(item.thumbnail, width: 60, fit: BoxFit.cover)
                            : const Icon(Icons.video_file, size: 40),
                      ),
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.formatType),
                      trailing: const Icon(Icons.play_circle_fill, color: Colors.blue),
                      onTap: () => _openFile(item.filePath, context),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
