import 'package:flutter/material.dart';
import '../utils/palette.dart';
import 'package:intl/intl.dart';
import '../services/settings_service.dart';

class ClockZone extends StatefulWidget {
  const ClockZone({Key? key}) : super(key: key);

  @override
  State<ClockZone> createState() => _ClockZoneState();
}

class _ClockZoneState extends State<ClockZone> {
  DateTime _currentTime = DateTime.now();
  final List<String> _zones = ["WIB", "WITA", "WIT", "GMT"];

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
        _startClock();
      }
    });
  }

  String _getTimeByZone() {
    // read current zone from SettingsService
    final currentZone = SettingsService.timeZone.value;
    Duration offset;
    switch (currentZone) {
      case "WITA":
        offset = const Duration(hours: 8);
        break;
      case "WIT":
        offset = const Duration(hours: 9);
        break;
      case "GMT":
        offset = const Duration(hours: 0);
        break;
      default:
        offset = const Duration(hours: 7);
    }
    final zoneTime = _currentTime.toUtc().add(offset);
    return DateFormat('HH:mm:ss').format(zoneTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.paymentCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(Icons.access_time, color: Palette.accent),
            const SizedBox(width: 10),
            Text(_getTimeByZone(),
                style: TextStyle(
                  color: Palette.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          ]),
          // Use a ValueListenableBuilder so changes to the global timezone
          // (from SettingsService) immediately update the dropdown and time.
          ValueListenableBuilder<String>(
            valueListenable: SettingsService.timeZone,
            builder: (context, selectedZone, _) => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Palette.paymentCard,
                icon: Icon(Icons.arrow_drop_down, color: Palette.accent),
                value: selectedZone,
                style: TextStyle(color: Palette.accent, fontWeight: FontWeight.bold),
                items: _zones.map((zone) {
                  return DropdownMenuItem(
                    value: zone,
                    child: Text(zone,
                        style: TextStyle(
                            color: Palette.accent, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) SettingsService.setTimeZone(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
