import 'package:YouTube_MP3_Downloader/YoutubeMP3.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube MP3 Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.red[400]
      ),
      debugShowCheckedModeBanner: false,
      home: YoutubeMP3(),
    );
  }
}

