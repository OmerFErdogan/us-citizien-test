import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🚀 Production-ready flashcard widget
class ProductionFlashcard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback? onFlip;
  final FlipStyle style;
  final Duration duration;
  final bool enableHaptics;

  const ProductionFlashcard({
    Key? key,
    required this.front,
    required this.back,
    required this.isFlipped,
    this.onFlip,
    this.style = FlipStyle.fade,
    this.duration = const Duration(milliseconds: 300),
    this.enableHaptics = true,
  }) : super(key: key);

  @override
  State<ProductionFlashcard> createState() => _ProductionFlashcardState();
}

enum FlipStyle {
  fade,          // En performanslı
  slide,         // Smooth ve modern
  scale,         // iOS-like
  rotation,      // 3D effect ama optimize
}

class _ProductionFlashcardState extends State<ProductionFlashcard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(ProductionFlashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      _handleFlip();
    }
  }

  void _handleFlip() {
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact(); // 📱 Haptic feedback
    }
    
    if (widget.isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFlip,
      child: _buildAnimatedCard(),
    );
  }

  Widget _buildAnimatedCard() {
    switch (widget.style) {
      case FlipStyle.fade:
        return _buildFadeTransition();
      case FlipStyle.slide:
        return _buildSlideTransition();
      case FlipStyle.scale:
        return _buildScaleTransition();
      case FlipStyle.rotation:
        return _buildRotationTransition();
    }
  }

  // ⚡ En performanslı - Fade transition
  Widget _buildFadeTransition() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: widget.duration,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: widget.isFlipped 
              ? Container(key: const ValueKey('back'), child: widget.back)
              : Container(key: const ValueKey('front'), child: widget.front),
        );
      },
    );
  }

  // 🌊 Modern slide transition
  Widget _buildSlideTransition() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(_animation),
              child: widget.back,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0.0, -1.0),
              ).animate(_animation),
              child: widget.front,
            ),
          ],
        );
      },
    );
  }

  // 📱 iOS-style scale transition
  Widget _buildScaleTransition() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final scale = 1.0 - (_animation.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: AnimatedSwitcher(
            duration: widget.duration,
            child: widget.isFlipped 
                ? Container(key: const ValueKey('back'), child: widget.back)
                : Container(key: const ValueKey('front'), child: widget.front),
          ),
        );
      },
    );
  }

  // 🎯 Optimize edilmiş 3D rotation
  Widget _buildRotationTransition() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isShowingFront = _animation.value < 0.5;
        
        // ✅ Tek widget render - performance optimization
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value * 3.14159),
          child: isShowingFront ? widget.front : widget.back,
        );
      },
    );
  }
}

// 🎮 Advanced gesture handling
class GestureFlashcard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final VoidCallback? onKnown;
  final VoidCallback? onUnknown;
  final VoidCallback? onFlip;

  const GestureFlashcard({
    Key? key,
    required this.front,
    required this.back,
    this.onKnown,
    this.onUnknown,
    this.onFlip,
  }) : super(key: key);

  @override
  State<GestureFlashcard> createState() => _GestureFlashcardState();
}

class _GestureFlashcardState extends State<GestureFlashcard> {
  bool _isFlipped = false;
  Offset _panStart = Offset.zero;
  double _panDistance = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Transform.translate(
        offset: Offset(_panDistance, 0),
        child: ProductionFlashcard(
          front: widget.front,
          back: widget.back,
          isFlipped: _isFlipped,
          style: FlipStyle.fade, // En performanslı seçenek
        ),
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    widget.onFlip?.call();
  }

  void _handlePanStart(DragStartDetails details) {
    _panStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _panDistance = details.localPosition.dx - _panStart.dx;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_panDistance.abs() > 100) {
      if (_panDistance > 0) {
        widget.onKnown?.call();
      } else {
        widget.onUnknown?.call();
      }
    }
    
    setState(() {
      _panDistance = 0;
    });
  }
}

// 📊 Performance monitoring widget
class PerformanceFlashcard extends StatefulWidget {
  final Widget child;
  final Function(double fps)? onFpsUpdate;

  const PerformanceFlashcard({
    Key? key,
    required this.child,
    this.onFpsUpdate,
  }) : super(key: key);

  @override
  State<PerformanceFlashcard> createState() => _PerformanceFlashcardState();
}

class _PerformanceFlashcardState extends State<PerformanceFlashcard> {
  int _frameCount = 0;
  DateTime _lastTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // 🚀 Render optimization
      child: widget.child,
    );
  }

  void _trackFPS() {
    _frameCount++;
    final now = DateTime.now();
    final diff = now.difference(_lastTime);
    
    if (diff.inMilliseconds >= 1000) {
      final fps = _frameCount / diff.inSeconds;
      widget.onFpsUpdate?.call(fps);
      _frameCount = 0;
      _lastTime = now;
    }
  }
}
