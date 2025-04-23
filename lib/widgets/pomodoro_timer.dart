import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroTimer extends StatefulWidget {
  final int workDuration;
  final int breakDuration;
  final int longBreakDuration;
  final int sessionsUntilLongBreak;

  const PomodoroTimer({
    super.key,
    this.workDuration = 25,
    this.breakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsUntilLongBreak = 4,
  });

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  late Timer _timer;
  int _timeLeft = 0;
  int _sessionsCompleted = 0;
  bool _isRunning = false;
  bool _isWorkTime = true;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.workDuration * 60;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer.cancel();
          _isRunning = false;
          _handleTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    setState(() {
      _isRunning = false;
    });

    _timer.cancel();
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _isWorkTime ? widget.workDuration * 60 : widget.breakDuration * 60;
    });
  }

  void _handleTimerComplete() {
    if (_isWorkTime) {
      _sessionsCompleted++;
      if (_sessionsCompleted >= widget.sessionsUntilLongBreak) {
        _startBreak(true);
      } else {
        _startBreak(false);
      }
    } else {
      _startWork();
    }
  }

  void _startBreak(bool isLongBreak) {
    setState(() {
      _isWorkTime = false;
      _timeLeft = isLongBreak ? widget.longBreakDuration * 60 : widget.breakDuration * 60;
      if (isLongBreak) {
        _sessionsCompleted = 0;
      }
    });
    _startTimer();
  }

  void _startWork() {
    setState(() {
      _isWorkTime = true;
      _timeLeft = widget.workDuration * 60;
    });
    _startTimer();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isWorkTime ? 'Work Time' : 'Break Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              _formatTime(_timeLeft),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetTimer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sessions completed: $_sessionsCompleted/${widget.sessionsUntilLongBreak}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
} 