import 'dart:io';

import 'package:YouTube_MP3_Downloader/Models/YouTubeVideo.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeMP3 extends StatefulWidget {
  @override
  _YoutubeMP3State createState() => _YoutubeMP3State();
}

class _YoutubeMP3State extends State<YoutubeMP3> {
  TextEditingController urlYouTube = TextEditingController();
  YoutubeExplode _youtubeExplode = YoutubeExplode();

  Result videos;
  bool isFetching = false;
  bool fetchSuccess = false;
  bool isDownloading = false;
  bool downloadsuccess = false;
  String status = "Download ";
  String progress = "";
  Map<String, String> headers = {
    "X-Requested-With": "XMLHttpRequest",
  };

  Map<String, String> body;

  void insertBody(String urlYouTube) {
    body = {"url": urlYouTube};
  }

  //----------------------------------Get Video Info

  Future<Video> getInfo() async {
    setState(() {
      progress = "";
      status = "Download MP3";
      downloadsuccess = false;
      isDownloading = false;
      isFetching = true;
      fetchSuccess = false;
    });
    var video = await _youtubeExplode.videos.get(urlYouTube.text);
    try {
      setState(() {
        isFetching = false;
        fetchSuccess = true;
      });
      
    } catch (e) {
      print(e.toString());
      setState(() {
        isFetching = true;
        fetchSuccess = false;
      });
    }

    print("${video.thumbnails.highResUrl}\n${video.title}\n${video.duration.toString()}\n${video.id}");
    
    return video;
    
  }

  //----------------------------------Get Download Link

  Future<Video> directURI() async {
    var video = await _youtubeExplode.videos.get(urlYouTube.text);
    print('Title: ${video.title}');
    _youtubeExplode.close(); 
    return video;
  }

//----------------------------------Download MP3
  Future<void> downloadMp3() async {

    // Here you should validate the given input or else an error
    // will be thrown.
    var id = VideoId(urlYouTube.text.trim());
    var video = await _youtubeExplode.videos.get(id);

    // // Display info about this video.
    // await showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       content: Text(
    //           'Title: ${video.title}, Duration: ${video.duration}'),
    //     );
    //   },
    // );

    // Request permission to write in an external directory.
    // (In this case downloads)
    await Permission.storage.request();

    // Get the streams manifest and the audio track.
    var manifest = await _youtubeExplode.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.withHighestBitrate();

    // Build the directory.
    var dir = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_MUSIC);
    var filePath = path.join(dir, '${video.title}.mp3');

    // Open the file to write.
    var file = File(filePath);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into our file.
    await _youtubeExplode.videos.streamsClient.get(audio).pipe(fileStream);
    /*
    If you want to show a % of download, you should listen
    to the stream instead of using `pipe` and compare
    the current downloaded streams to the totalBytes,
    see an example ii example/video_download.dart
    */

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    // Show that the file was downloaded.
    await showDialog(
      context: context,
      builder: (context) {
        _youtubeExplode.close();
        return AlertDialog(
          content: Text( 'Download completed and saved to: $filePath'),
        );
      },
    );
  }

  void nothingHere() {
    print("Just Nothing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchBar(),
        backgroundColor: Color.fromARGB(255, 30, 30, 30),
        centerTitle: true,
      ),
      body: bodyPart(),
    );
  }

  Widget bodyPart() {
    return Container(
      color: Color.fromARGB(255, 30, 30, 30),
      child: Center(
        child: isFetching
            ? progressScreen()
            : fetchSuccess
                ? downloadScreen()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "YouYube MP3 Downloader",
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "By Allen Dev",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Icon(
                        FontAwesomeIcons.youtube,
                        color: Colors.redAccent,
                        size: 45.0,
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget progressScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            'Getting Data ...',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        )
      ],
    );
  }

  Widget downloadScreen() {
    return FutureBuilder<Video>(
      future: getInfo(),
      builder: (BuildContext context, AsyncSnapshot<Video> snapshot) {
        if(snapshot.hasData){
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                height: 300.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(19.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Image(
                        image: NetworkImage(snapshot.data.thumbnails.highResUrl),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    labelTitle("Title : ", snapshot.data.title),
                    SizedBox(
                      height: 8.0,
                    ),
                    labelTitle("Duration : ", snapshot.data.duration.toString()),
                    SizedBox(
                      height: 8.0,
                    ),
                    FlatButton(
                      onPressed: () async {
                        downloadMp3(); 
                      },
                      child: Container(
                        height: 40.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                          color: downloadsuccess == true
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              50.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              status,
                              style: TextStyle(color: Colors.black, fontSize: 16.0),
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            Icon(
                              isDownloading
                                  ? FontAwesomeIcons.spinner
                                  : downloadsuccess
                                      ? FontAwesomeIcons.check
                                      : FontAwesomeIcons.download,
                              color: Colors.black,
                              size: 20.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        progress,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        else{
          return progressScreen();
        }
      }
    );
  }

  Widget labelTitle(String title, String inpute) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 17.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: Text(
            inpute,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }

  Widget searchBar() {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(100, 255, 255, 255),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: TextFormField(
              controller: urlYouTube,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Video URL ...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
                icon: IconButton(
                  onPressed: () async {
                    getInfo();
                  },
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
