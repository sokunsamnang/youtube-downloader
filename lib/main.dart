import 'package:flutter/services.dart';
import 'package:youtube_mp3_downloader/YoutubeMP3.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      title: 'YouTube MP3 Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.red[400]
      ),
      home: YoutubeMP3(),
    );
  }
}

