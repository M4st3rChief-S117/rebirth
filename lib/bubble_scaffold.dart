import 'package:base_flutter_template/animated_bubble_menu.dart';
import 'package:flutter/material.dart';

class BubbleScaffold extends StatelessWidget {
  final Widget body;
  final List<AnimatedBubbleItem> menuItems;
  final BubbleMenuConfig? config;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  const BubbleScaffold({
    super.key,
    required this.body,
    required this.menuItems,
    this.config,
    this.appBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBubbleMenu(
      config: config ?? const BubbleMenuConfig(),
      items: menuItems,
      child: Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        body: body,
      ),
    );
  }
}
