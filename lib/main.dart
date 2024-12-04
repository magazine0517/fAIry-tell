import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Children\'s Story',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StoryPage(),
    );
  }
}

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  List<String> _sentences = [];
  bool _isOriginal = true;
  Timer? _timer;
  bool _isTiming = false;
  Random _random = Random();
  List<int> _replacedIndices = [];

  @override
  void initState() {
    super.initState();
    _loadStory('assets/little_red_original.txt');
  }

  Future<void> _loadStory(String path) async {
    String storyText = await rootBundle.loadString(path);
    setState(() {
      _sentences = storyText.split(RegExp(r'[\n]')).where((sentence) => sentence.isNotEmpty).toList();
      _replacedIndices.clear();
    });
  }

  void _toggleStory() {
    if (!_isTiming) {
      // Start the timer and change the button text to "Stop"
      setState(() {
        _isTiming = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_replacedIndices.length < _sentences.length) {
            _replaceRandomLine();
          } else {
            timer.cancel();
          }
        });
      });
    } else {
      // Stop the timer and revert to the original story
      _timer?.cancel();
      _loadStory('assets/little_red_original.txt');
      setState(() {
        _isOriginal = true;
        _isTiming = false;
      });
    }
  }

  Future<void> _replaceRandomLine() async {
    String fakeStoryText = await rootBundle.loadString('assets/little_red_fake.txt');
    List<String> fakeSentences = fakeStoryText.split(RegExp(r'[\n]')).where((sentence) => sentence.isNotEmpty).toList();

    if (_sentences.isNotEmpty) {
      int index;
      do {
        index = _random.nextInt(_sentences.length);
      } while (_replacedIndices.contains(index));

      setState(() {
        _sentences[index] = fakeSentences[index % fakeSentences.length];
        _replacedIndices.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SvgPicture.asset(
            'assets/background.svg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(
              'assets/castle.svg',
              height: 150,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Story Title and Button
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          '小紅帽',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTiming ? Colors.pinkAccent : Colors.white,
                      ),
                      onPressed: _toggleStory,
                      child: Text(_isTiming ? 'Stop' : 'Start'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Story Text
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _sentences
                          .map((sentence) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$sentence',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
