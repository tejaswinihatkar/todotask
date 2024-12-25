import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PomodoroTimer extends StatefulWidget {
  final String taskName;
  final int duration; // Duration in minutes

  const PomodoroTimer({
    super.key,
    required this.taskName,
    required this.duration,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Timer _timer;
  int _remainingTime = 0;
  bool _isRunning = false;
  bool _isWorkPeriod = true;
  bool _isAlarmPlaying = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration * 60; // Convert minutes to seconds
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    if (_isAlarmPlaying) {
      _audioPlayer.stop();
    }
    super.dispose();
  }

  // Function to play alarm sound
  void _playAlarm() async {
    await _audioPlayer.play(AssetSource('alarms/alarm_ap4.wav'));
    setState(() {
      _isAlarmPlaying = true;
    });
  }

  // Function to stop the alarm sound
  void _stopAlarm() async {
    await _audioPlayer.stop();
    setState(() {
      _isAlarmPlaying = false;
    });
  }

  // Start the timer
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _onComplete();
        timer.cancel();
      }
    });
  }

  // Handle timer completion
  void _onComplete() {
    _playAlarm();
    setState(() {
      _isWorkPeriod = !_isWorkPeriod;
      _remainingTime = widget.duration * 60;
      _isRunning = false;
    });
  }

  // Pause the timer
  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer.cancel();
  }

  // Reset the timer
  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingTime = widget.duration * 60;
    });
    _timer.cancel();
  }

  // Convert remaining time to MM:SS format
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pomodoro - ${widget.taskName}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal[800],
        elevation: 6,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[300]!, Colors.teal[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add the logo/image above the "Focus on Work!" sentence
                Image.asset(
                  'assets/images/work.png', // Replace with your image path
                  height: 200, // Set a suitable height for the logo
                  width: 200,  // Set a suitable width for the logo
                ),
                const SizedBox(height: 20), // Space between logo and text

                // Task/Work Status Title
                Text(
                  _isWorkPeriod ? 'Focus on Work!' : 'Time for a Break!',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Timer Display
                Text(
                  _formatTime(_remainingTime),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Timer Control Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isRunning ? 'Pause' : 'Start',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? Colors.orange : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        elevation: 6,
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    ElevatedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        elevation: 6,
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Stop Alarm Button
                    if (_isAlarmPlaying)
                      ElevatedButton.icon(
                        onPressed: _stopAlarm,
                        icon: const Icon(Icons.stop, color: Colors.white),
                        label: const Text(
                          'Stop Alarm',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          elevation: 6,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
