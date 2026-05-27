// weekly_schedule_page.dart
import 'dart:convert';
import 'package:base_flutter_template/app_colors.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:base_flutter_template/animated_bubble_menu.dart';
import 'package:base_flutter_template/shared_menu_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({super.key});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class ActivityData {
  final String name;
  final Color color;

  ActivityData({required this.name, required this.color});

  Map<String, dynamic> toJson() => {'name': name, 'color': color.toARGB32()};

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(name: json['name'], color: Color(json['color']));
  }
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  // Schedule data: Map<dayIndex, Map<hour, activity>>
  late Map<int, Map<int, ActivityData>> schedule;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _storageKey = 'weekly_schedule';

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final List<int> hours = List.generate(24, (i) => i);

  // Predefined colors for activities
  final List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    // Initialize empty schedule
    schedule = {for (int i = 0; i < 7; i++) i: {}};

    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final String? savedData = await _storage.read(key: _storageKey);

      if (savedData != null) {
        final Map<String, dynamic> decoded = json.decode(savedData);
        final Map<int, Map<int, ActivityData>> loadedSchedule = {};

        for (int day = 0; day < 7; day++) {
          loadedSchedule[day] = {};
          final dayData = decoded[day.toString()] as Map<String, dynamic>?;
          if (dayData != null) {
            dayData.forEach((hourStr, activityJson) {
              final hour = int.parse(hourStr);
              loadedSchedule[day]![hour] = ActivityData.fromJson(
                json.decode(activityJson.toString()),
              );
            });
          }
        }

        setState(() {
          schedule = loadedSchedule;
        });
      }
    } catch (e) {
      print('Error loading schedule: $e');
    }
  }

  Future<void> _saveSchedule() async {
    try {
      final Map<String, dynamic> toSave = {};

      for (int day = 0; day < 7; day++) {
        final dayData = <String, String>{};

        for (var entry in schedule[day]!.entries) {
          dayData[entry.key.toString()] = json.encode(entry.value.toJson());
        }

        toSave[day.toString()] = dayData;
      }

      await _storage.write(key: _storageKey, value: json.encode(toSave));
    } catch (e) {
      print('Errore saving schedule: $e');
    }
  }

  void _addOrEditActivity(int day, int hour, {ActivityData? existingActivity}) {
    final bool isEditing = existingActivity != null;
    String activityName = existingActivity?.name ?? '';
    int endHour = hour;
    Color selectedColor = existingActivity?.color ?? Colors.blue;
    int selectedColorIndex = availableColors.indexOf(selectedColor);
    if (selectedColorIndex == -1) selectedColorIndex = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Edit Activity for ${days[day]} at $hour:00'
                    : 'Add Activity for ${days[day]} at $hour:00',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: activityName),
                    decoration: const InputDecoration(
                      labelText: 'Activity',
                      hintText: 'e.g., Work, Meeting, Gym',
                    ),
                    onChanged: (value) {
                      activityName = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('End hour: '),
                      Expanded(
                        child: Slider(
                          value: endHour.toDouble(),
                          min: hour.toDouble(),
                          max: 23.0,
                          divisions: 23 - hour,
                          onChanged: (value) {
                            setStateDialog(() {
                              endHour = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text('$endHour:00'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Color: '),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: List.generate(availableColors.length, (
                            index,
                          ) {
                            return GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  selectedColorIndex = index;
                                  selectedColor = availableColors[index];
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: availableColors[index],
                                  shape: BoxShape.circle,
                                  border: selectedColorIndex == index
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 3,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        final oldEndHour = _getActivityEndHour(day, hour);
                        for (int h = hour; h <= oldEndHour; h++) {
                          schedule[day]!.remove(h);
                        }
                      }

                      for (int h = hour; h <= endHour; h++) {
                        if (activityName.isNotEmpty) {
                          schedule[day]![h] = ActivityData(
                            name: activityName,
                            color: selectedColor,
                          );
                        }
                      }

                      _saveSchedule();
                    });

                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _getActivityEndHour(int day, int startHour) {
    final activity = schedule[day]?[startHour];
    if (activity == null) return startHour;

    int endHour = startHour;
    for (int h = startHour + 1; h < 24; h++) {
      final nextActivity = schedule[day]?[h];
      if (nextActivity?.name == activity.name &&
          nextActivity?.color == activity.color) {
        endHour = h;
      } else {
        break;
      }
    }

    return endHour;
  }

  void _removeActivity(int day, int hour) {
    final activity = schedule[day]?[hour];
    if (activity == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Activity'),
        content: Text(
          'Do you want to remove "${activity.name}" at ${days[day]} $hour:00?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final endHour = _getActivityEndHour(day, hour);

                for (int h = hour; h <= endHour; h++) {
                  schedule[day]!.remove(h);
                }
                _saveSchedule();
              });

              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBubbleMenu(
      config: const BubbleMenuConfig(
        mainBubbleColor: Colors.teal,
        menuRadius: 150,
        mainBubbleSize: 70,
        menuItemSize: 55,
        animationCurve: Curves.elasticOut,
        closeOnItemTap: true,
      ),
      items: getSharedMenuItems(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Schedule'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All'),
                    content: const Text(
                      'Are you sure you want to clear the entire schedule?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            schedule = {for (int i = 0; i < 7; i++) i: {}};
                            _saveSchedule();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          child: DataTable2(
            columnSpacing: 0,
            horizontalMargin: 0,
            minWidth: 600,
            fixedLeftColumns: 1,
            fixedTopRows: 1,
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade100),
            columns: [
              const DataColumn2(
                label: SizedBox(
                  width: 80,
                  height: 60,
                  child: CustomPaint(
                    painter: DiagonalSplitPainter(),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Text(
                            'Day',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                size: ColumnSize.S,
              ),
              ...days.map(
                (day) => DataColumn2(
                  label: Center(
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  size: ColumnSize.S,
                ),
              ),
            ],
            rows: List.generate(hours.length, (hourIndex) {
              final hour = hours[hourIndex];

              return DataRow2(
                cells: [
                  DataCell(
                    SizedBox(width: 80, child: Center(child: Text('$hour:00'))),
                  ),
                  ...List.generate(days.length, (dayIndex) {
                    final activity = schedule[dayIndex]?[hour];
                    final hasActivity = activity != null;

                    return DataCell(
                      GestureDetector(
                        onTap: () => _addOrEditActivity(
                          dayIndex,
                          hour,
                          existingActivity: activity,
                        ),
                        onLongPress: () {
                          if (hasActivity) {
                            _removeActivity(dayIndex, hour);
                          }
                        },
                        child: SizedBox(
                          width: 100,
                          height: 50,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: hasActivity
                                  ? activity.color.opaque(0.3)
                                  : Colors.white,
                            ),
                            child: Text(
                              activity?.name ?? '',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: hasActivity
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                color: hasActivity
                                    ? activity.color
                                    : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DiagonalSplitPainter extends CustomPainter {
  const DiagonalSplitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
