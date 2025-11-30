import 'package:flutter/material.dart';
import '../services/in_app_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<InAppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await InAppNotificationService.all();
    setState(() {
      _items = all;
      _loading = false;
    });
    // mark all read when viewing
    await InAppNotificationService.markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi'), backgroundColor: const Color(0xFF012D5A), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Belum ada notifikasi'))
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final it = _items[i];
                    return ListTile(
                      title: Text(it.title),
                      subtitle: Text(it.body),
                      trailing: Text(TimeOfDay.fromDateTime(it.time).format(context)),
                      tileColor: it.read ? null : Colors.blue.shade50,
                    );
                  },
                ),
    );
  }
}
