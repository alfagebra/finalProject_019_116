import 'package:flutter/material.dart';
import '../services/in_app_notification_service.dart';
import '../screens/notifications_screen.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({Key? key}) : super(key: key);

  Future<void> _showRecent(BuildContext context) async {
    final items = await InAppNotificationService.all();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notifikasi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () async {
                          await InAppNotificationService.markAllRead();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Tandai semua dibaca'),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada notifikasi')))
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (c, i) {
                            final it = items[i];
                            return ListTile(
                              title: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(it.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: Text(TimeOfDay.fromDateTime(it.time).format(context), style: const TextStyle(fontSize: 12)),
                              tileColor: it.read ? null : Colors.blue.shade50,
                              onTap: () async {
                                await InAppNotificationService.markRead(it.id);
                                // show details
                                if (!ctx.mounted) return;
                                showDialog(
                                  context: ctx,
                                  builder: (dctx) => AlertDialog(
                                    title: Text(it.title),
                                    content: Text('${it.body}\n\n${it.time}'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Tutup')),
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.of(dctx).pop();
                                            Navigator.of(ctx).pop();
                                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                                          },
                                          child: const Text('Lihat semua'))
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                          },
                          child: const Text('Buka semua notifikasi'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: InAppNotificationService.unreadCount,
      builder: (context, unread, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Use a Material + InkWell with a guaranteed minimum tap target
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  await _showRecent(context);
                },
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: Icon(Icons.notifications_none, color: Colors.white)),
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
