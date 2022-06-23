String html(String soundFile) {
  return '''<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <title>Audio API</title>
    </head>
    <body>
        <script>
            console.clear();
            let audioCtx;
            let panner;
            let listener;
            let source;
            //let oscillator;
            let volumeController;
            let started = false;
            let xPos = 30;
            let yPos = 30;
            let zPos = 300;
            let freq = 512;
            let vol = 0.5;

            function log(str) {
                // window.flutter_inappwebview.callHandler('debugLog', str)
                console.error(str);
            }

            async function _things() {
                try {
                    log("_things called");

                    let AudioContext = window.AudioContext || window.webkitAudioContext;
                    audioCtx = new AudioContext();

                    // setup panner
                    panner = audioCtx.createPanner();
                    //panner.panningModel = 'HRTF';
                    panner.distanceModel = "inverse";
                    panner.refDistance = 1;
                    panner.maxDistance = 10000;
                    panner.rolloffFactor = 0;
                    panner.coneInnerAngle = 360;
                    panner.coneOuterAngle = 0;
                    panner.coneOuterGain = 0;

                    listener = audioCtx.listener;

                    // set oriantation and position of panner and listener
                    panner.setOrientation(0, 0, 0);

                    listener.setOrientation(0, 0, 1, 0, 1, 0);
                    listener.setPosition(xPos, yPos, zPos);
                    source = audioCtx.createBufferSource();
                    volumeController = audioCtx.createGain();
                    volumeController.gain.value = vol;
                    loadAudio();
                } catch (e) {
                    log("" + e);
                }
            }

            function _setEndListener() {
                source.addEventListener("ended", () => {
                    if (!source.loop) {
                        playing = false;
                    }
                });
            }

            function loopAudio(loop) {
                source.loop = loop;
            }

            async function init_sound() {
                try {
                    log("init_sound called");

                    if (!audioCtx) {
                        await _things();
                    }
                    // check if context is in suspended state (autoplay policy)
                    if (audioCtx.state === "suspended") {
                        audioCtx.resume();
                    }
                } catch (e) {
                    log("" + e);
                }
            }

            function start() {
                if (!started) {
                    source.start(0);
                    started = true;
                }
            }

            function play() {
                playing = true;
                audioCtx.resume();
            }

            function pause() {
                playing = false;
                audioCtx.suspend();
            }

            function isReady() {
                return started;
            }

            function isPlaying() {
                return started ? playing : false;
            }

            function stop() {
                try {
                    log("stop called");

                    if (started) {
                        source.stop(0);
                        started = false;
                    }
                    started = false;
                } catch (e) {
                    log("" + e);
                }
            }

            function setListenerPosition(x, y) {
                try {
                    log("setListenerPosition called");

                    listener.setPosition(x, y, 0);
                } catch (e) {
                    log("" + e);
                }
            }

            function set_volume(v) {
                try {
                    log("setVolume called");

                    vol = v;
                    volumeController.gain.value = vol;
                } catch (e) {
                    log("" + e);
                }
            }

            function loadAudio(src = "https://sfmygozkc1b6pom6ld5krvdok3dpc2eh.ui.nabu.casa/local/ping.mp3") {
                try {
                    log("loadAudio called");

                    request = new XMLHttpRequest();

                    request.open("GET", src, true);
                    request.responseType = "arraybuffer";
                    request.onload = function () {
                        audioCtx.decodeAudioData(request.response, onDecoded);
                        log("data");
                    };
                    request.onerror;

                    function onDecoded(buffer) {
                        source.buffer = buffer;
                        //source.connect(audioCtx.destination);
                        source.connect(panner);
                        panner.connect(volumeController);
                        volumeController.connect(audioCtx.destination);
                    }
                    request.send();
                } catch (e) {
                    log("" + e);
                }
            }

            function restart() {
                pause();
                stop();

                oldBuff = source.buffer;

                source.disconnect(panner);

                source = audioCtx.createBufferSource();
                source.buffer = oldBuff;
                source.connect(panner);
                start();
            }
        </script>
    </body>
</html>
''';
}
