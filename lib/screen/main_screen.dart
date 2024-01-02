import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:talk/services/signalling.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({
    super.key,
    required this.title,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final TextEditingController _textEditingController = TextEditingController();
  String? roomId;

  bool isCameraOn = false;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.pink[400],
        middle: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: TextField(
                          controller: _textEditingController,
                          decoration: const InputDecoration(
                            hintText: "Enter Room ID",
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        signaling.joinRoom(
                            _textEditingController.text, _remoteRenderer);

                        setState(() {});
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        RTCVideoView(
                          _remoteRenderer,
                          mirror: false,
                          filterQuality: FilterQuality.low,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                        const Positioned(
                          child: Text(
                            "Shashinoor",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.pink[200],
                                borderRadius: BorderRadius.circular(300)),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        isCameraOn
                            ? Stack(
                                children: [
                                  RTCVideoView(
                                    _localRenderer,
                                    mirror: false,
                                    filterQuality: FilterQuality.low,
                                    objectFit: RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                                  ),
                                  const Positioned(
                                    child: Text(
                                      "Shashinoor",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(300)),
                                child: const Text(
                                  "Shashinoor's Ghimire Local Video Feed",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.pink[200],
                                borderRadius: BorderRadius.circular(300)),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: Container(
          decoration: BoxDecoration(
              color: Colors.pink[200],
              borderRadius: BorderRadius.circular(300)),
          height: 60,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Material(
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () async {
                      var room_id = await signaling.createRoom(
                        _remoteRenderer,
                      );
                      setState(() {
                        roomId = room_id;
                        _textEditingController.text = roomId!;
                      });
                    },
                    icon: const Icon(Icons.call),
                  ),
                ),
                Material(
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {
                      signaling.openUserMedia(_localRenderer, _remoteRenderer);
                      if (isCameraOn) {
                        signaling.hangUp(_localRenderer);
                        isCameraOn = false;
                      } else {
                        signaling.openUserMedia(
                            _localRenderer, _remoteRenderer);
                        isCameraOn = true;
                      }
                      setState(() {});
                    },
                    icon: isCameraOn
                        ? const Icon(Icons.videocam)
                        : const Icon(Icons.videocam_off),
                  ),
                ),
                Material(
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                  ),
                ),
                Material(
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.call_end),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
