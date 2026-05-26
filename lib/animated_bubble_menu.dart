// animated_bubble_menu.dart
import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedBubbleMenu extends StatefulWidget {
  final Widget child;
  final List<AnimatedBubbleItem> items;
  final BubbleMenuConfig config;

  const AnimatedBubbleMenu({
    super.key,
    required this.child,
    required this.items,
    this.config = const BubbleMenuConfig(),
  });

  @override
  State<AnimatedBubbleMenu> createState() => _AnimatedBubbleMenuState();
}

class BubbleMenuConfig {
  final Color mainBubbleColor;
  final double mainBubbleSize;
  final double menuItemSize;
  final double menuRadius;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool closeOnItemTap;
  final double bubbleElasticity;

  const BubbleMenuConfig({
    this.mainBubbleColor = Colors.blue,
    this.mainBubbleSize = 70.0,
    this.menuItemSize = 50.0,
    this.menuRadius = 120.0,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.elasticOut,
    this.closeOnItemTap = true,
    this.bubbleElasticity = 1.5,
  });
}

class AnimatedBubbleItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  AnimatedBubbleItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _AnimatedBubbleMenuState extends State<AnimatedBubbleMenu>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemBounceAnimations;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    );

    _bounceAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600),
      ),
    );

    _itemBounceAnimations = List.generate(
      widget.items.length,
      (index) =>
          TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 30),
            TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
            TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 20),
            TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 30),
          ]).animate(
            CurvedAnimation(
              parent: _itemControllers[index],
              curve: Curves.decelerate,
            ),
          ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        _animateItemsWithBurst();
      } else {
        _controller.reverse();
        _resetItems();
      }
    });
  }

  void _animateItemsWithBurst() {
    for (int i = 0; i < _itemControllers.length; i++) {
      final delay = Duration(
        milliseconds: 50 + (i * 30) + (Random().nextInt(20)),
      );

      Future.delayed(delay, () {
        if (mounted) {
          _itemControllers[i].forward();

          if (i == 0) {
            _pulseMainBubble();
          }
        }
      });
    }
  }

  void _pulseMainBubble() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _resetItems() {
    for (var controller in _itemControllers) {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Add a tap absorber to close menu when tapping outside
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
        // Menu overlay with proper constraints
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height:
                widget.config.menuRadius + widget.config.mainBubbleSize + 50,
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Menu items
                ..._buildMenuItems(),
                // Main bubble
                _buildMainBubble(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> items = [];

    // Upper half: from left (180°) to right (360°/0°) going through top (270°)
    double startAngle = 180; // Left side
    double totalArc = -180; // 180 degrees
    // double angleStep = totalArc / (widget.items.length - 1);
    double angleStep = widget.items.length > 1
        ? totalArc / (widget.items.length - 1)
        : 0;

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      // This will go: 180° (left) -> 270° (top) -> 360° (right)
      final double angle = startAngle + (i * angleStep);
      final double angleInRadians = angle * (pi / 180);

      items.add(
        AnimatedBuilder(
          animation: _itemControllers[i],
          builder: (context, child) {
            final double radiusProgress = Curves.elasticOut.transform(
              min(1.0, _itemControllers[i].value * 1.2),
            );

            final double wobbleX =
                sin(_itemControllers[i].value * pi * 4) *
                5 *
                (1 - _itemControllers[i].value);
            final double wobbleY =
                cos(_itemControllers[i].value * pi * 4) *
                5 *
                (1 - _itemControllers[i].value);

            final double radius = widget.config.menuRadius * radiusProgress;
            final double x = radius * cos(angleInRadians) + wobbleX;
            final double y = radius * sin(angleInRadians) + wobbleY;

            return Positioned(
              left:
                  (MediaQuery.of(context).size.width / 2) -
                  (widget.config.menuItemSize / 2) +
                  x,
              bottom: (widget.config.mainBubbleSize / 2) + y,
              child: Transform.scale(
                scale: _itemBounceAnimations[i].value,
                child: Opacity(
                  opacity: _itemControllers[i].value,
                  child: _buildMenuItem(item, i),
                ),
              ),
            );
          },
        ),
      );
    }
    return items;
  }

  Widget _buildMenuItem(AnimatedBubbleItem item, int index) {
    return GestureDetector(
      onTap: () {
        if (widget.config.closeOnItemTap) {
          _toggleMenu();
        }
        item.onTap();
      },
      child: Container(
        width: widget.config.menuItemSize,
        height: widget.config.menuItemSize,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              item.color,
              item.color.withOpacity(0.8),
              item.color.withOpacity(0.6),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 24),
                if (_isExpanded)
                  Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBubble() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double squishX =
            1.0 +
            (sin(_controller.value * pi * 2) * 0.1 * (1 - _controller.value));
        final double squishY =
            1.0 -
            (sin(_controller.value * pi * 2) * 0.1 * (1 - _controller.value));

        return Positioned(
          bottom: 0,
          left:
              MediaQuery.of(context).size.width / 2 -
              (widget.config.mainBubbleSize / 2),
          child: GestureDetector(
            onTap: _toggleMenu,
            child: Transform.scale(
              scale: _isExpanded ? _bounceAnimation.value : 1.0,
              child: Transform(
                transform: Matrix4.identity()..scale(squishX, squishY, 1.0),
                alignment: Alignment.center,
                child: Container(
                  width: widget.config.mainBubbleSize,
                  height: widget.config.mainBubbleSize,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.config.mainBubbleColor,
                        widget.config.mainBubbleColor.withOpacity(0.7),
                        widget.config.mainBubbleColor.withOpacity(0.4),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.config.mainBubbleColor.withOpacity(0.4),
                        blurRadius: 20 * (1 + _controller.value),
                        spreadRadius: 5 * _controller.value,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Bubble highlight
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Bubble "burst" effect when opening
                      if (_isExpanded && _controller.value < 0.3)
                        ...List.generate(5, (index) {
                          final burstProgress = _controller.value * 3;
                          final burstAngle = index * (2 * pi / 5);
                          final burstDistance = 20 * burstProgress;
                          return Positioned(
                            left: 35 + cos(burstAngle) * burstDistance,
                            top: 35 + sin(burstAngle) * burstDistance,
                            child: Opacity(
                              opacity: 1 - burstProgress,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      Icon(
                        _isExpanded ? Icons.close : Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
