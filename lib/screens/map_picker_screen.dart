import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sharemeal/constants/app_theme.dart';

class PickedLocation {
  final LatLng latLng;
  final String address;
  const PickedLocation({required this.latLng, required this.address});
}

class MapPickerScreen extends StatefulWidget {
  /// Pass an initial location to center the map on (optional).
  final LatLng? initial;
  const MapPickerScreen({super.key, this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapCtrl;
  LatLng _picked = const LatLng(20.5937, 78.9629); // India center default
  String _address = 'Tap the map to pick a location';
  bool _loading = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    if (widget.initial != null) {
      _picked = widget.initial!;
      _reverseGeocode(_picked);
    }
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _loading = true);
    try {
      final placemarks = await placemarkFromCoordinates(
          pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street, p.subLocality, p.locality,
          p.administrativeArea, p.country,
        ].where((s) => s != null && s.isNotEmpty).toList();
        setState(() => _address = parts.join(', '));
      }
    } catch (_) {
      setState(() => _address =
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _snack('Location permission permanently denied. Enable it in settings.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapCtrl.move(ll, 15);
      setState(() => _picked = ll);
      await _reverseGeocode(ll);
    } catch (e) {
      _snack('Could not get location: $e');
    } finally {
      setState(() => _locating = false);
    }
  }

  void _onTap(TapPosition _, LatLng pos) {
    setState(() => _picked = pos);
    _reverseGeocode(pos);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.terr,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // ── Map ──────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: widget.initial ?? _picked,
            initialZoom: widget.initial != null ? 15 : 5,
            onTap: _onTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sharemeal.app',
              maxZoom: 19,
              additionalOptions: const {
                'crossOrigin': 'anonymous',
              },
            ),
            MarkerLayer(markers: [
              Marker(
                point: _picked,
                width: 48,
                height: 56,
                child: Column(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: AppGradients.sageButton,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                            color: AppColors.sage.withOpacity(0.45),
                            blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.restaurant_rounded,
                          color: Colors.white, size: 18),
                    ),
                    CustomPaint(
                      size: const Size(12, 8),
                      painter: _PinTailPainter(),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),

        // ── Top AppBar overlay ───────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.heroBar,
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('Pick Location',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pop(
                            context,
                            PickedLocation(
                                latLng: _picked, address: _address)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Confirm',
                          style: TextStyle(
                              color: AppColors.sage,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),

        // ── Bottom address card ──────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20, offset: const Offset(0, -4))],
            ),
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.fieldBorder,
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.sage.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.sage, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Selected Location',
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    _loading
                        ? Row(children: [
                            SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.sage),
                            ),
                            const SizedBox(width: 8),
                            Text('Fetching address...',
                                style: AppTextStyles.bodySmall),
                          ])
                        : Text(_address,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.ink2)),
                    const SizedBox(height: 4),
                    Text(
                      '${_picked.latitude.toStringAsFixed(5)}, '
                      '${_picked.longitude.toStringAsFixed(5)}',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10.5, color: AppColors.ink3),
                    ),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              Text('Tap anywhere on the map to move the pin',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.ink3, fontSize: 11)),
            ]),
          ),
        ),

        // ── My Location FAB ──────────────────────────────────────────
        Positioned(
          right: 16,
          bottom: 180,
          child: FloatingActionButton.small(
            heroTag: 'myLoc',
            backgroundColor: AppColors.white,
            elevation: 4,
            onPressed: _locating ? null : _goToMyLocation,
            child: _locating
                ? SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.sage))
                : const Icon(Icons.my_location_rounded,
                    color: AppColors.sage, size: 20),
          ),
        ),

        // ── Zoom controls ────────────────────────────────────────────
        Positioned(
          right: 16,
          bottom: 240,
          child: Column(children: [
            _ZoomBtn(
              icon: Icons.add,
              onTap: () {
                final camera = _mapCtrl.camera;
                _mapCtrl.move(camera.center, camera.zoom + 1);
              },
            ),
            const SizedBox(height: 4),
            _ZoomBtn(
              icon: Icons.remove,
              onTap: () {
                final camera = _mapCtrl.camera;
                _mapCtrl.move(camera.center, camera.zoom - 1);
              },
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Pin tail painter ──────────────────────────────────────────────────────────
class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sage
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Zoom button ───────────────────────────────────────────────────────────────
class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: AppColors.ink2),
      ),
    );
  }
}
