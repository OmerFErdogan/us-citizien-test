import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:io';

/// 📊 Gerçek zamanlı FPS ölçümü için widget
class FPSMonitor extends StatefulWidget {
  final Widget child;
  final ValueChanged<double>? onFpsUpdate;
  final bool showOverlay;

  const FPSMonitor({
    Key? key,
    required this.child,
    this.onFpsUpdate,
    this.showOverlay = true,
  }) : super(key: key);

  @override
  State<FPSMonitor> createState() => _FPSMonitorState();
}

class _FPSMonitorState extends State<FPSMonitor> {
  double _fps = 0.0;
  int _frameCount = 0;
  late DateTime _lastTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _lastTime = DateTime.now();
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateFPS();
    });

    // Frame callback ile her frame'i say
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    _frameCount++;
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _calculateFPS() {
    final now = DateTime.now();
    final timeDiff = now.difference(_lastTime);
    
    if (timeDiff.inMilliseconds > 0) {
      final fps = _frameCount / timeDiff.inSeconds;
      setState(() {
        _fps = fps;
      });
      
      widget.onFpsUpdate?.call(fps);
      _frameCount = 0;
      _lastTime = now;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: _buildFPSIndicator(),
          ),
      ],
    );
  }

  Widget _buildFPSIndicator() {
    Color indicatorColor;
    if (_fps >= 55) {
      indicatorColor = Colors.green;
    } else if (_fps >= 45) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${_fps.toStringAsFixed(1)} FPS',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 🧠 Memory kullanım ölçümü
class MemoryMonitor extends StatefulWidget {
  final Widget child;
  final ValueChanged<double>? onMemoryUpdate;
  final bool showOverlay;

  const MemoryMonitor({
    Key? key,
    required this.child,
    this.onMemoryUpdate,
    this.showOverlay = true,
  }) : super(key: key);

  @override
  State<MemoryMonitor> createState() => _MemoryMonitorState();
}

class _MemoryMonitorState extends State<MemoryMonitor> {
  double _memoryMB = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateMemoryUsage();
    });
  }

  void _updateMemoryUsage() {
    // ProcessInfo.currentRss ile memory usage alınabilir
    // Basit bir hesaplama için
    final rss = ProcessInfo.currentRss;
    final memoryMB = rss / (1024 * 1024); // Bytes to MB
    
    setState(() {
      _memoryMB = memoryMB;
    });
    
    widget.onMemoryUpdate?.call(memoryMB);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay)
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            right: 16,
            child: _buildMemoryIndicator(),
          ),
      ],
    );
  }

  Widget _buildMemoryIndicator() {
    Color indicatorColor;
    if (_memoryMB <= 100) {
      indicatorColor = Colors.green;
    } else if (_memoryMB <= 200) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${_memoryMB.toStringAsFixed(1)} MB',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ⏱️ Performance logging utility
class PerformanceLogger {
  static final Map<String, Stopwatch> _timers = {};
  static final List<PerformanceMetric> _metrics = [];

  /// Timer başlat
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// Timer durdur ve logla
  static void stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      final metric = PerformanceMetric(
        name: name,
        duration: timer.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
      _metrics.add(metric);
      
      // Console'a yazdır
      print('⏱️ [$name] ${timer.elapsedMilliseconds}ms');
      
      // Uyarı: Yavaş operasyonlar için
      if (timer.elapsedMilliseconds > 100) {
        print('⚠️ Slow operation detected: $name (${timer.elapsedMilliseconds}ms)');
      }
      
      _timers.remove(name);
    }
  }

  /// Fonksiyon execution time'ını ölç
  static T measure<T>(String name, T Function() function) {
    startTimer(name);
    final result = function();
    stopTimer(name);
    return result;
  }

  /// Async fonksiyon execution time'ını ölç
  static Future<T> measureAsync<T>(String name, Future<T> Function() function) async {
    startTimer(name);
    final result = await function();
    stopTimer(name);
    return result;
  }

  /// Tüm metrikleri al
  static List<PerformanceMetric> getMetrics() => List.from(_metrics);

  /// Metrikleri temizle
  static void clearMetrics() => _metrics.clear();

  /// Metrikleri CSV formatında export et
  static String exportMetricsCSV() {
    final header = 'Operation,Duration(ms),Timestamp\n';
    final rows = _metrics.map((m) => 
      '${m.name},${m.duration},${m.timestamp.toIso8601String()}'
    ).join('\n');
    return header + rows;
  }

  /// Performans raporu oluştur
  static String generateReport() {
    if (_metrics.isEmpty) return 'No performance data available';

    final groupedMetrics = <String, List<PerformanceMetric>>{};
    for (final metric in _metrics) {
      groupedMetrics.putIfAbsent(metric.name, () => []).add(metric);
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 Performance Report');
    buffer.writeln('=' * 40);

    for (final entry in groupedMetrics.entries) {
      final metrics = entry.value;
      final avg = metrics.map((m) => m.duration).reduce((a, b) => a + b) / metrics.length;
      final max = metrics.map((m) => m.duration).reduce((a, b) => a > b ? a : b);
      final min = metrics.map((m) => m.duration).reduce((a, b) => a < b ? a : b);

      buffer.writeln('\n${entry.key}:');
      buffer.writeln('  Count: ${metrics.length}');
      buffer.writeln('  Average: ${avg.toStringAsFixed(2)}ms');
      buffer.writeln('  Min: ${min}ms');
      buffer.writeln('  Max: ${max}ms');
    }

    return buffer.toString();
  }
}

/// 📊 Performance metric data class
class PerformanceMetric {
  final String name;
  final int duration;
  final DateTime timestamp;

  const PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, duration: ${duration}ms, timestamp: $timestamp)';
  }
}

/// 🔄 Widget rebuild tracker
class RebuildTracker extends StatefulWidget {
  final Widget child;
  final String name;
  final VoidCallback? onExcessiveRebuilds;

  const RebuildTracker({
    Key? key,
    required this.child,
    required this.name,
    this.onExcessiveRebuilds,
  }) : super(key: key);

  @override
  State<RebuildTracker> createState() => _RebuildTrackerState();
}

class _RebuildTrackerState extends State<RebuildTracker> {
  int _buildCount = 0;
  DateTime? _lastBuild;
  static const int _rebuildThreshold = 10;
  static const Duration _timeWindow = Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    final now = DateTime.now();
    
    // İlk build değilse timing kontrolü yap
    if (_lastBuild != null) {
      final timeSinceLastBuild = now.difference(_lastBuild!);
      
      // Çok hızlı rebuild kontrolü
      if (timeSinceLastBuild.inMilliseconds < 50) {
        print('⚠️ Very fast rebuild in ${widget.name}: ${timeSinceLastBuild.inMilliseconds}ms');
      }
      
      // Time window içinde çok fazla rebuild kontrolü
      if (_buildCount > _rebuildThreshold && 
          now.difference(_lastBuild!).compareTo(_timeWindow) < 0) {
        print('🚨 Excessive rebuilds in ${widget.name}: $_buildCount rebuilds in ${_timeWindow.inSeconds}s');
        widget.onExcessiveRebuilds?.call();
      }
    }
    
    _lastBuild = now;
    print('🔄 ${widget.name} rebuilt ($_buildCount times)');
    
    return RepaintBoundary(
      child: widget.child,
    );
  }
}

/// 📊 Comprehensive performance dashboard
class PerformanceDashboard extends StatefulWidget {
  final Widget child;
  final bool showFPS;
  final bool showMemory;
  final bool showMetrics;

  const PerformanceDashboard({
    Key? key,
    required this.child,
    this.showFPS = true,
    this.showMemory = true,
    this.showMetrics = false,
  }) : super(key: key);

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  bool _isDashboardVisible = false;
  double _currentFPS = 0.0;
  double _currentMemory = 0.0;

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // FPS monitoring ekle
    if (widget.showFPS) {
      child = FPSMonitor(
        showOverlay: !widget.showMetrics,
        onFpsUpdate: (fps) => setState(() => _currentFPS = fps),
        child: child,
      );
    }

    // Memory monitoring ekle
    if (widget.showMemory) {
      child = MemoryMonitor(
        showOverlay: !widget.showMetrics,
        onMemoryUpdate: (memory) => setState(() => _currentMemory = memory),
        child: child,
      );
    }

    // Metrics dashboard ekle
    if (widget.showMetrics) {
      child = Stack(
        children: [
          child,
          if (_isDashboardVisible) _buildMetricsDashboard(),
          _buildToggleButton(),
        ],
      );
    }

    return child;
  }

  Widget _buildMetricsDashboard() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📊 Performance Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetric('FPS', _currentFPS.toStringAsFixed(1), 
                _currentFPS >= 55 ? Colors.green : _currentFPS >= 45 ? Colors.orange : Colors.red),
            _buildMetric('Memory', '${_currentMemory.toStringAsFixed(1)} MB',
                _currentMemory <= 100 ? Colors.green : _currentMemory <= 200 ? Colors.orange : Colors.red),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton('Clear', Colors.orange, () {
                  PerformanceLogger.clearMetrics();
                }),
                const SizedBox(width: 8),
                _buildActionButton('Report', Colors.blue, () {
                  final report = PerformanceLogger.generateReport();
                  print(report);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        heroTag: "performance_toggle",
        backgroundColor: Colors.blue,
        onPressed: () => setState(() => _isDashboardVisible = !_isDashboardVisible),
        child: Icon(_isDashboardVisible ? Icons.close : Icons.analytics),
      ),
    );
  }
}
