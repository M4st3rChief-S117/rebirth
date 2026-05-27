// shared_menu_items.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'animated_bubble_menu.dart';

List<AnimatedBubbleItem> getSharedMenuItems(BuildContext context) {
  return [
    AnimatedBubbleItem(
      icon: Icons.calendar_today,
      label: 'Weekly Schedule',
      color: Colors.blue,
      onTap: () {
        context.go('/weekly-schedule');
      },
    ),
    AnimatedBubbleItem(
      icon: Icons.checklist,
      label: 'ToDo List',
      color: Colors.green,
      onTap: () {
        context.go('/todo-list');
      },
    ),
    AnimatedBubbleItem(
      icon: Icons.shopping_bag,
      label: 'Shopping List',
      color: Colors.orange,
      onTap: () {
        context.go('/shopping-list');
      },
    ),
    AnimatedBubbleItem(
      icon: Icons.car_repair,
      label: 'Car Maintenance',
      color: Colors.red,
      onTap: () {
        context.go('/car-maintenance');
      },
    ),
  ];
}
