import 'package:flutter/material.dart';

class OptimizedFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback? onTap;
  final Duration duration;

  const OptimizedFlipCard({
    Key? key,
    required this.front,
    required this.back,
    required this.isFlipped,
    this.onTap,
    this.duration = const Duration(milliseconds: 400), // Daha hızlı
  }) : super(key: key);

  @override
  State<OptimizedFlipCard> createState() => _OptimizedFlipCardState();
}

class _OptimizedFlipCardState extends State<OptimizedFlipCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // 🚀 Basit scale + fade animasyonu (GPU friendly)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  @override
  void didUpdateWidget(OptimizedFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 🎯 Basit conditional rendering - tek widget render
          final showFront = _controller.value < 0.5;
          
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: showFront 
                  ? Container(key: const ValueKey('front'), child: widget.front)
                  : Container(key: const ValueKey('back'), child: widget.back),
            ),
          );
        },
      ),
    );
  }
}

// 🎨 Modern slide animation alternative
class SlideFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback? onTap;

  const SlideFlipCard({
    Key? key,
    required this.front,
    required this.back,
    required this.isFlipped,
    this.onTap,
  }) : super(key: key);

  @override
  State<SlideFlipCard> createState() => _SlideFlipCardState();
}

class _SlideFlipCardState extends State<SlideFlipCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 🌊 Smooth slide transition
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(SlideFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
      onTap: widget.onTap,
      child: Stack(
        children: [
          // Back card
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(_controller),
            child: widget.back,
          ),
          // Front card
          SlideTransition(
            position: _slideAnimation,
            child: widget.front,
          ),
        ],
      ),
    );
  }
}

// 🎯 iOS-style card flip (most performant)
class iOSStyleFlipCard extends StatelessWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback? onTap;
  final Duration duration;

  const iOSStyleFlipCard({
    Key? key,
    required this.front,
    required this.back,
    required this.isFlipped,
    this.onTap,
    this.duration = const Duration(milliseconds: 350),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // 📱 iOS-style flip transition
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final isShowingFront = child!.key == const ValueKey('front');
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isShowingFront ? -1.0 : 1.0;
              
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(tilt),
                child: child,
              );
            },
            child: child,
          );
        },
        child: isFlipped 
            ? Container(key: const ValueKey('back'), child: back)
            : Container(key: const ValueKey('front'), child: front),
      ),
    );
  }
}
