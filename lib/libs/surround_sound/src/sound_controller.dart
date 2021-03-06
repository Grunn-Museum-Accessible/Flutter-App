import 'dart:async';

import 'package:app/libs/surround_sound/src/web_html.dart';
import 'package:app/libs/surround_sound/surround_sound.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SoundController {
  InAppWebViewController? _controller;
  Completer<InAppWebViewController> _webController =
      Completer<InAppWebViewController>();

  late HeadlessInAppWebView webview;
  late AngleConverter angleConverter;

  void dispose() {
    pause().then((_) {
      stop().then((_) {
        webview.dispose();
      });
    });
  }

  SoundController(String soundFile) {
    // create a angle converter and webview
    angleConverter = AngleConverter();
    webview = HeadlessInAppWebView(
        // load the html and insert the url
        initialData: InAppWebViewInitialData(
          data: html,
        ),
        // set the options for
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            mediaPlaybackRequiresUserGesture:
                false, // play media without user input
          ),
        ),
        onLoadStop: (controller, Uri? url) {
          init();
          start();
          complete(controller);
        })
      ..run();
  }
  void complete(InAppWebViewController controller) {
    if (_webController.isCompleted) {
      _webController = Completer<InAppWebViewController>();
      _controller = null;
    }
    _webController.complete(controller);
  }

  Future init() async {
    _controller = await _webController.future;
    await _controller!.evaluateJavascript(source: 'init_sound()');
  }

  Future _check() async {
    if (_controller == null) {
      await init();
    }
  }

  Future start() async {
    await _check();
    await _controller?.evaluateJavascript(source: 'start()');
  }

  Future restart() async {
    await _check();
    await _controller?.evaluateJavascript(source: 'restart()');
  }

  Future play() async {
    await _check();
    await _controller?.evaluateJavascript(source: 'play()');
  }

  Future pause() async {
    await _check();
    await _controller?.evaluateJavascript(source: 'pause()');
  }

  Future stop() async {
    await _check();
    await _controller?.evaluateJavascript(source: 'stop()');
  }

  Future sendJS(String str) async {
    await _check();
    await _controller?.evaluateJavascript(source: str);
  }

  Future loopAudio(bool loop) async {
    await _check();
    await _controller?.evaluateJavascript(source: 'loopAudio($loop)');
  }

  Future loadAudioURL(String url) async {
    await _check();
    await _controller?.evaluateJavascript(source: 'loadAudio($url)');
  }

  Future setVolume(double vol) async {
    await _check();
    vol = vol.clamp(0.0, 1.0);
    await _controller?.evaluateJavascript(source: 'set_volume($vol);');
  }

  Future setAngle(num angle) async {
    await _check();
    var coords = angleConverter.angleToCoords(angle);
    // log(coords.toString());
    await _controller?.evaluateJavascript(
        source: 'setListenerPosition(${coords['x']}, ${coords['y']})');
  }
}
