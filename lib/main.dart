import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/downloader_bloc.dart';
import 'bloc/downloader_event.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloaderBloc()..add(LoadLibraryEvent()),
      child: MaterialApp(
        title: 'YT Downloader',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0F13),
          cardColor: const Color(0xFF1E1E24),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF0000), // YouTube Red
            secondary: Color(0xFF3EA6FF), // Neon Blue
            surface: Color(0xFF1E1E24),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F0F13),
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
