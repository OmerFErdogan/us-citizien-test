# 📊 Flutter Performance Monitoring Guide

## 🚀 Built-in Flutter DevTools

### **1. DevTools Başlatma**
```bash
# Terminal'de uygulamayı debug modda çalıştır
flutter run --debug

# DevTools'u aç
flutter pub global activate devtools
flutter pub global run devtools
```

### **2. Performance Tab**
- **Timeline View:** Frame render sürelerini görüntüle
- **Memory Tab:** Memory usage ve leaks
- **CPU Profiler:** Kod performance hotspots
- **Network Tab:** API call performansı

### **3. Widget Inspector**
- Widget tree analizi
- Rebuild count tracking
- Unnecessary rebuilds detection

## 📱 Real-time Performance Monitoring

### **FPS Counter Widget**
```dart
class FPSMonitor extends StatefulWidget {
  final Widget child;
  final ValueChanged<double>? onFpsUpdate;

  const FPSMonitor({
    Key? key,
    required this.child,
    this.onFpsUpdate,
  }) : super(key: key);

  @override
  State<FPSMonitor> createState() => _FPSMonitorState();
}

class _FPSMonitorState extends State<FPSMonitor> {
  int _frameCount = 0;
  double _fps = 0.0;
  late DateTime _lastTime;
  late SchedulerBinding _schedulerBinding;

  @override
  void initState() {
    super.initState();
    _lastTime = DateTime.now();
    _schedulerBinding = SchedulerBinding.instance;
    _schedulerBinding.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    _frameCount++;
    final now = DateTime.now();
    final diff = now.difference(_lastTime);
    
    if (diff.inMilliseconds >= 1000) {
      setState(() {
        _fps = _frameCount / diff.inSeconds;
        widget.onFpsUpdate?.call(_fps);
      });
      _frameCount = 0;
      _lastTime = now;
    }
    
    _schedulerBinding.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _fps < 50 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'FPS: ${_fps.toStringAsFixed(1)}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
```

### **Memory Usage Monitor**
```dart
class MemoryMonitor extends StatefulWidget {
  final Widget child;

  const MemoryMonitor({Key? key, required this.child}) : super(key: key);

  @override
  State<MemoryMonitor> createState() => _MemoryMonitorState();
}

class _MemoryMonitorState extends State<MemoryMonitor> {
  double _memoryUsage = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateMemoryUsage();
    });
  }

  void _updateMemoryUsage() async {
    final info = await DeviceInfoPlugin().androidInfo;
    // Memory calculation logic here
    setState(() {
      _memoryUsage = /* calculated memory usage */;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 100,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _memoryUsage > 80 ? Colors.orange : Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'RAM: ${_memoryUsage.toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

## 🔧 Advanced Performance Tracking

### **Custom Performance Logger**
```dart
class PerformanceLogger {
  static final Map<String, Stopwatch> _timers = {};
  static final List<PerformanceMetric> _metrics = [];

  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  static void stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      _metrics.add(PerformanceMetric(
        name: name,
        duration: timer.elapsedMilliseconds,
        timestamp: DateTime.now(),
      ));
      print('⏱️ $name: ${timer.elapsedMilliseconds}ms');
    }
  }

  static void logFrameTime(String operation, VoidCallback callback) {
    final stopwatch = Stopwatch()..start();
    callback();
    stopwatch.stop();
    print('🖼️ Frame $operation: ${stopwatch.elapsedMilliseconds}ms');
  }

  static List<PerformanceMetric> getMetrics() => List.from(_metrics);
  
  static void clearMetrics() => _metrics.clear();
  
  static void exportMetrics() {
    final csv = _metrics.map((m) => '${m.name},${m.duration},${m.timestamp}').join('\n');
    print('📊 Performance Metrics:\n$csv');
  }
}

class PerformanceMetric {
  final String name;
  final int duration;
  final DateTime timestamp;

  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
  });
}
```

### **Widget Performance Tracker**
```dart
class PerformanceWrapper extends StatefulWidget {
  final Widget child;
  final String name;

  const PerformanceWrapper({
    Key? key,
    required this.child,
    required this.name,
  }) : super(key: key);

  @override
  State<PerformanceWrapper> createState() => _PerformanceWrapperState();
}

class _PerformanceWrapperState extends State<PerformanceWrapper> {
  int _buildCount = 0;
  DateTime? _lastBuild;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    final now = DateTime.now();
    
    if (_lastBuild != null) {
      final timeSinceLastBuild = now.difference(_lastBuild!);
      if (timeSinceLastBuild.inMilliseconds < 100) {
        print('⚠️ Frequent rebuild detected in ${widget.name}: ${timeSinceLastBuild.inMilliseconds}ms');
      }
    }
    
    _lastBuild = now;
    
    print('🔄 ${widget.name} built $_buildCount times');
    
    return RepaintBoundary(
      child: widget.child,
    );
  }
}
```

## 📱 Device-specific Performance

### **Adaptive Performance Manager**
```dart
class PerformanceManager {
  static DevicePerformanceLevel _performanceLevel = DevicePerformanceLevel.high;
  
  static Future<void> initialize() async {
    _performanceLevel = await _detectDevicePerformance();
  }
  
  static Future<DevicePerformanceLevel> _detectDevicePerformance() async {
    // RAM check
    final info = await DeviceInfoPlugin().androidInfo;
    final ramGB = info.totalMemory / (1024 * 1024 * 1024);
    
    // CPU check (simplified)
    final cpuCores = Platform.numberOfProcessors;
    
    if (ramGB >= 6 && cpuCores >= 6) {
      return DevicePerformanceLevel.high;
    } else if (ramGB >= 3 && cpuCores >= 4) {
      return DevicePerformanceLevel.medium;
    } else {
      return DevicePerformanceLevel.low;
    }
  }
  
  static Duration getAnimationDuration() {
    switch (_performanceLevel) {
      case DevicePerformanceLevel.high:
        return Duration(milliseconds: 300);
      case DevicePerformanceLevel.medium:
        return Duration(milliseconds: 400);
      case DevicePerformanceLevel.low:
        return Duration(milliseconds: 500);
    }
  }
  
  static bool shouldUseAdvancedAnimations() {
    return _performanceLevel == DevicePerformanceLevel.high;
  }
}

enum DevicePerformanceLevel { low, medium, high }
```

## 🔬 Benchmarking Suite

### **Animation Performance Test**
```dart
class AnimationBenchmark extends StatefulWidget {
  @override
  State<AnimationBenchmark> createState() => _AnimationBenchmarkState();
}

class _AnimationBenchmarkState extends State<AnimationBenchmark>
    with TickerProviderStateMixin {
  
  late AnimationController _controller;
  final List<double> _frameTimes = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _runBenchmark();
  }
  
  void _runBenchmark() async {
    for (int i = 0; i < 100; i++) {
      final stopwatch = Stopwatch()..start();
      
      await _controller.forward();
      await _controller.reverse();
      
      stopwatch.stop();
      _frameTimes.add(stopwatch.elapsedMilliseconds.toDouble());
    }
    
    _analyzeResults();
  }
  
  void _analyzeResults() {
    final average = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final max = _frameTimes.reduce((a, b) => a > b ? a : b);
    final min = _frameTimes.reduce((a, b) => a < b ? a : b);
    
    print('📊 Animation Benchmark Results:');
    print('Average: ${average.toStringAsFixed(2)}ms');
    print('Max: ${max.toStringAsFixed(2)}ms');
    print('Min: ${min.toStringAsFixed(2)}ms');
    print('Frames > 16ms: ${_frameTimes.where((t) => t > 16).length}');
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(); // Benchmark widget
  }
}
```

## 📊 Performance Dashboard

### **Real-time Performance Dashboard**
```dart
class PerformanceDashboard extends StatefulWidget {
  final Widget child;

  const PerformanceDashboard({Key? key, required this.child}) : super(key: key);

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  double _fps = 0.0;
  double _memoryUsage = 0.0;
  int _rebuilds = 0;
  bool _showDashboard = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showDashboard)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📊 Performance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _buildMetric('FPS', _fps.toStringAsFixed(1), _fps < 50 ? Colors.red : Colors.green),
                  _buildMetric('Memory', '${_memoryUsage.toStringAsFixed(1)}%', _memoryUsage > 80 ? Colors.orange : Colors.blue),
                  _buildMetric('Rebuilds', _rebuilds.toString(), _rebuilds > 10 ? Colors.yellow : Colors.green),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            onPressed: () => setState(() => _showDashboard = !_showDashboard),
            child: Icon(Icons.analytics),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Text('$label: $value', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
```

## 🎯 Kullanım Örnekleri

### **Flashcard Performance Integration**
```dart
// flashcard_screen.dart içinde
@override
Widget build(BuildContext context) {
  return PerformanceDashboard(
    child: FPSMonitor(
      onFpsUpdate: (fps) {
        if (fps < 45) {
          print('⚠️ Performance warning: FPS dropped to $fps');
        }
      },
      child: Scaffold(
        appBar: AppBar(/* ... */),
        body: PerformanceWrapper(
          name: 'FlashcardBody',
          child: /* existing body content */,
        ),
      ),
    ),
  );
}

void _flipCard() {
  PerformanceLogger.startTimer('card_flip');
  
  HapticFeedback.lightImpact();
  
  PerformanceLogger.logFrameTime('flip_animation', () {
    if (_isCardFlipped) {
      setState(() => _isCardFlipped = false);
    } else {
      setState(() => _isCardFlipped = true);
    }
  });
  
  PerformanceLogger.stopTimer('card_flip');
}
```

## 📊 Komut Satırı Araçları

### **Flutter Performance Commands**
```bash
# 1. Performance profiling
flutter run --profile --trace-startup

# 2. Memory analysis
flutter analyze --no-fatal-warnings

# 3. APK size analysis
flutter build apk --analyze-size

# 4. Build performance
flutter build apk --verbose

# 5. Test performance
flutter test --coverage
flutter test integration_test/performance_test.dart
```

## 📱 Production Monitoring

### **Crashlytics Integration**
```dart
// Firebase Performance monitoring
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static Future<void> trackCardFlipPerformance() async {
    final trace = FirebasePerformance.instance.newTrace('card_flip');
    await trace.start();
    
    // Perform card flip
    
    await trace.stop();
  }
  
  static void trackCustomMetric(String name, double value) {
    FirebasePerformance.instance.newTrace(name)
      ..putMetric('duration', value.toInt())
      ..start()
      ..stop();
  }
}
```

Bu araçlarla performansı gerçek zamanlı olarak takip edebilir, sorunları erkenden tespit edebilir ve kullanıcı deneyimini optimize edebilirsin! 🚀
