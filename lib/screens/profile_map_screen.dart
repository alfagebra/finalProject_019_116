import 'package:flutter/material.dart';
import '../utils/palette.dart';
import '../widgets/custom_app_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/debouncer.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/nearby_service.dart';

class ProfileMapScreen extends StatefulWidget {
  const ProfileMapScreen({Key? key}) : super(key: key);

  @override
  State<ProfileMapScreen> createState() => _ProfileMapScreenState();
}

class _ProfileMapScreenState extends State<ProfileMapScreen> {
  Position? _pos;
  List<Map<String, dynamic>> _nearby = [];
  bool _loading = true;
  final MapController _mapController = MapController();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    _initLocationAndNearby();
  }

  Future<void> _initLocationAndNearby() async {
    setState(() => _loading = true);
    final granted = await LocationService.requestPermission();
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      return;
    }
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _pos = pos;
    });
    if (pos != null) {
      final found = await NearbyService.getNearby(pos, 1000); // 1 km
      if (!mounted) return;
      setState(() {
        _nearby = found;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  double _radiusForZoom(double zoom) {
    // crude mapping: higher zoom => smaller radius
    if (zoom >= 16) return 200;
    if (zoom >= 14) return 500;
    return 1000;
  }

  Future<void> _fetchNearbyForCenter(LatLng center, double zoom) async {
    setState(() => _loading = true);
    try {
      final fakePos = Position(
        latitude: center.latitude,
        longitude: center.longitude,
        timestamp: DateTime.now(),
        accuracy: 5,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      final radius = _radiusForZoom(zoom);
      final found = await NearbyService.getNearby(fakePos, radius);
      if (!mounted) return;
      setState(() {
        _nearby = found;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.premiumBackground,
      appBar: const CustomAppBar(
        title: 'Peta Profil',
        backgroundColor: Palette.premiumBackground,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pos == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Lokasi tidak tersedia.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _initLocationAndNearby,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: LatLng(_pos!.latitude, _pos!.longitude),
                        zoom: 15.0,
                        onPositionChanged: (p, _) {
                          final center = p.center;
                          final zoom = p.zoom;
                          if (center == null || zoom == null) return;
                          _debouncer.run(() => _fetchNearbyForCenter(center, zoom));
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'id.app.fix_eyd',
                        ),
                        CircleLayer(circles: [
                          CircleMarker(
                            point: LatLng(_pos!.latitude, _pos!.longitude),
                            color: Colors.blueAccent.withOpacity(0.15),
                            borderColor: Colors.blueAccent.withOpacity(0.3),
                            borderStrokeWidth: 2,
                            useRadiusInMeter: true,
                            radius: 20, // show small accuracy circle
                          )
                        ]),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 56,
                              height: 56,
                              point: LatLng(_pos!.latitude, _pos!.longitude),
                              builder: (ctx) => const Icon(
                                Icons.my_location,
                                color: Colors.blueAccent,
                                size: 36,
                              ),
                            ),
                            ..._nearby.map(
                              (poi) => Marker(
                                width: 48,
                                height: 48,
                                point: LatLng(
                                  poi['lat'] as double,
                                  poi['lng'] as double,
                                ),
                                builder: (ctx) => const Icon(
                                  Icons.location_on,
                                  color: Colors.orangeAccent,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // center crosshair
                    const Center(
                      child: Icon(
                        Icons.add_location_alt,
                        color: Colors.white54,
                        size: 28,
                      ),
                    ),

                    // recenter + refresh buttons
                    Positioned(
                      right: 12,
                      bottom: 120,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'recenter_loc',
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: () {
                              _mapController.move(LatLng(_pos!.latitude, _pos!.longitude), 16.0);
                            },
                            child: const Icon(Icons.my_location, color: Colors.blueAccent),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'refresh_nearby',
                            mini: true,
                            backgroundColor: Colors.orangeAccent,
                            onPressed: () {
                              final center = _mapController.center;
                              final zoom = _mapController.zoom;
                              _fetchNearbyForCenter(center, zoom);
                            },
                            child: const Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // swipe-up sheet for nearby list
                    DraggableScrollableSheet(
                      initialChildSize: 0.18,
                      minChildSize: 0.12,
                      maxChildSize: 0.6,
                      builder: (context, controller) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Palette.premiumBackground,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 6,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white38,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Text(
                                'Tempat terdekat',
                                style: TextStyle(color: Palette.accent, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _nearby.isEmpty
                                    ? const Center(child: Text('Tidak ada tempat terdekat', style: TextStyle(color: Colors.white70)))
                                    : ListView.builder(
                                        controller: controller,
                                        itemCount: _nearby.length,
                                        itemBuilder: (ctx, i) {
                                          final p = _nearby[i];
                                          final dist = (p['distance'] as double? ?? 0.0);
                                          final distStr = dist >= 1000 ? '${(dist / 1000).toStringAsFixed(2)} km' : '${dist.round()} m';
                                          return ListTile(
                                            leading: const Icon(Icons.location_on, color: Colors.orangeAccent),
                                            title: Text(p['name'] ?? 'POI', style: const TextStyle(color: Colors.white)),
                                            subtitle: Text(distStr, style: const TextStyle(color: Colors.white70)),
                                            onTap: () {
                                              _mapController.move(LatLng(p['lat'] as double, p['lng'] as double), 17.0);
                                            },
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}
