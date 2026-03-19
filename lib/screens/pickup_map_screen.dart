import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sharemeal/constants/app_theme.dart';

class PickupMapScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String address;
  final String foodItem;
  final String donorName;

  const PickupMapScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.address,
    required this.foodItem,
    required this.donorName,
  });

  @override
  State<PickupMapScreen> createState() => _PickupMapScreenState();
}

class _PickupMapScreenState extends State<PickupMapScreen>
    with TickerProviderStateMixin {
  late final MapController _mapCtrl;
  late final AnimationController _compassCtrl;

  // Pickup point
  late final LatLng _pickupPoint;

  // NGO's current location
  LatLng? _myLocation;
  bool _locating = false;

  // Structured address fields (parsed from widget.address or re-geocoded)
  String _street  = '';
  String _area    = '';
  String _city    = '';
  String _pincode = '';
  String _state   = '';
  String _country = '';

  // Map state
  bool _satelliteMode = false;
  double _mapRotation = 0;
  bool _showRoute     = false;

  // Distance
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _pickupPoint = LatLng(widget.lat, widget.lng);
    _mapCtrl     = MapController();
    _compassCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    // Parse address or re-geocode for structured fields
    _geocodePickup();

    // Listen to map rotation for compass
    _mapCtrl.mapEventStream.listen((event) {
      if (event is MapEventRotate) {
        setState(() => _mapRotation = event.camera.rotation);
      }
    });
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _compassCtrl.dispose();
    super.dispose();
  }

  // ── Geocode the pickup point for structured address ───────────────
  Future<void> _geocodePickup() async {
    try {
      final marks = await placemarkFromCoordinates(
          widget.lat, widget.lng);
      if (marks.isNotEmpty && mounted) {
        final p = marks.first;
        setState(() {
          _street  = _c(p.street);
          _area    = _c(p.subLocality).isNotEmpty
              ? _c(p.subLocality)
              : _c(p.locality);
          _city    = _c(p.locality).isNotEmpty
              ? _c(p.locality)
              : _c(p.subAdministrativeArea);
          _pincode = _c(p.postalCode);
          _state   = _c(p.administrativeArea);
          _country = _c(p.country);
        });
      }
    } catch (_) {
      // Fall back to the address string passed in
    }
  }

  String _c(String? s) => (s ?? '').trim();

  // ── Get NGO's current GPS location ───────────────────────────────
  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _snack('Location permission denied. Enable in settings.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _myLocation = ll;
        _distanceKm = _haversine(ll, _pickupPoint);
        _showRoute  = true;
      });
      _mapCtrl.move(ll, 14);
    } catch (e) {
      _snack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ── Focus back on pickup pin ──────────────────────────────────────
  void _focusPickup() => _mapCtrl.move(_pickupPoint, 16);

  // ── Reset map rotation to north ──────────────────────────────────
  void _resetNorth() => _mapCtrl.rotate(0);

  // ── Haversine distance ────────────────────────────────────────────
  double _haversine(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _rad(b.latitude  - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
  }

  double _rad(double deg) => deg * math.pi / 180;

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.terr,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Tile URL based on mode ────────────────────────────────────────
  String get _tileUrl => _satelliteMode
      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Build polyline points if we have both locations
    final polylinePoints = (_showRoute && _myLocation != null)
        ? [_myLocation!, _pickupPoint]
        : <LatLng>[];

    return Scaffold(
      body: Stack(children: [

        // ── Map ──────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _pickupPoint,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.sharemeal.app',
              maxZoom: 19,
            ),

            // Route line
            if (polylinePoints.length == 2)
              PolylineLayer(polylines: [
                Polyline(
                  points: polylinePoints,
                  strokeWidth: 3.5,
                  color: AppColors.sage,
                  pattern: const StrokePattern.dotted(),
                ),
              ]),

            // Markers
            MarkerLayer(markers: [
              // Pickup pin
              Marker(
                point: _pickupPoint,
                width: 48, height: 60,
                child: Column(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      gradient: AppGradients.sageButton,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: AppColors.sage.withAlpha(140),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.restaurant_rounded,
                        color: Colors.white, size: 20),
                  ),
                  CustomPaint(size: const Size(12, 8),
                      painter: _PinTailPainter(AppColors.sage)),
                ]),
              ),

              // My location pin
              if (_myLocation != null)
                Marker(
                  point: _myLocation!,
                  width: 44, height: 52,
                  child: Column(children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(
                            color: const Color(0xFF1A73E8).withAlpha(120),
                            blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.person_pin_circle_rounded,
                          color: Colors.white, size: 18),
                    ),
                    CustomPaint(size: const Size(10, 7),
                        painter: _PinTailPainter(const Color(0xFF1A73E8))),
                  ]),
                ),
            ]),
          ],
        ),

        // ── Top AppBar ───────────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.heroBar,
              boxShadow: [BoxShadow(
                  color: Colors.black.withAlpha(38),
                  blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Pickup Location',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      Text(widget.foodItem,
                          style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 11.5)),
                    ],
                  )),
                  // Layer toggle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _satelliteMode = !_satelliteMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withAlpha(80)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          _satelliteMode
                              ? Icons.map_outlined
                              : Icons.satellite_alt_rounded,
                          color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _satelliteMode ? 'Street' : 'Satellite',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 4),
                ]),
              ),
            ),
          ),
        ),

        // ── Distance badge (top-left below appbar) ───────────────────
        if (_distanceKm != null)
          Positioned(
            top: 100, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                    color: Colors.black.withAlpha(31),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.directions_walk_rounded,
                    size: 14, color: AppColors.sage),
                const SizedBox(width: 5),
                Text(
                  _distanceKm! < 1
                      ? '${(_distanceKm! * 1000).toStringAsFixed(0)} m away'
                      : '${_distanceKm!.toStringAsFixed(1)} km away',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sage)),
              ]),
            ),
          ),

        // ── Right-side controls ──────────────────────────────────────
        Positioned(
          right: 12,
          bottom: 260,
          child: Column(children: [
            // Compass
            GestureDetector(
              onTap: _resetNorth,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withAlpha(31),
                      blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Transform.rotate(
                  angle: -_mapRotation * math.pi / 180,
                  child: const Icon(Icons.explore_rounded,
                      size: 20, color: AppColors.terr),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Focus pickup
            _ControlBtn(
              icon: Icons.restaurant_rounded,
              color: AppColors.sage,
              onTap: _focusPickup,
              tooltip: 'Go to pickup',
            ),
            const SizedBox(height: 6),
            // Zoom in
            _ControlBtn(
              icon: Icons.add,
              onTap: () {
                final c = _mapCtrl.camera;
                _mapCtrl.move(c.center, c.zoom + 1);
              },
            ),
            const SizedBox(height: 4),
            // Zoom out
            _ControlBtn(
              icon: Icons.remove,
              onTap: () {
                final c = _mapCtrl.camera;
                _mapCtrl.move(c.center, c.zoom - 1);
              },
            ),
          ]),
        ),

        // ── My Location FAB ──────────────────────────────────────────
        Positioned(
          right: 12, bottom: 220,
          child: FloatingActionButton.small(
            heroTag: 'ngoLoc',
            backgroundColor: AppColors.white,
            elevation: 4,
            onPressed: _locating ? null : _goToMyLocation,
            child: _locating
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.sage))
                : const Icon(Icons.my_location_rounded,
                    color: AppColors.sage, size: 20),
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
                  color: Colors.black.withAlpha(31),
                  blurRadius: 20, offset: const Offset(0, -4))],
            ),
            padding: EdgeInsets.fromLTRB(
                20, 14, 20, bottomPad + 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.fieldBorder,
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 14),

              // Food + donor header
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: AppGradients.sageButton,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fastfood_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.foodItem,
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('Donor: ${widget.donorName}',
                        style: AppTextStyles.bodySmall),
                  ],
                )),
                if (_distanceKm != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.sage.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.sage.withAlpha(77)),
                    ),
                    child: Text(
                      _distanceKm! < 1
                          ? '${(_distanceKm! * 1000).toStringAsFixed(0)} m'
                          : '${_distanceKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sage)),
                  ),
              ]),
              const SizedBox(height: 12),

              // Structured address
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.sageBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.sage.withAlpha(51)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.sage, size: 15),
                      const SizedBox(width: 6),
                      Text('Pickup Address',
                          style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.sage,
                              fontSize: 11)),
                    ]),
                    const SizedBox(height: 8),
                    // Show structured fields if geocoded, else full string
                    if (_city.isNotEmpty || _state.isNotEmpty) ...[
                      if (_street.isNotEmpty)
                        _AddrRow(Icons.signpost_outlined, _street),
                      if (_area.isNotEmpty && _area != _city)
                        _AddrRow(Icons.holiday_village_outlined, _area),
                      if (_city.isNotEmpty)
                        _AddrRow(Icons.location_city_outlined, _city),
                      if (_pincode.isNotEmpty)
                        _AddrRow(Icons.pin_drop_outlined,
                            'PIN Code: $_pincode'),
                      if (_state.isNotEmpty)
                        _AddrRow(Icons.map_outlined, _state),
                      if (_country.isNotEmpty)
                        _AddrRow(Icons.flag_outlined, _country),
                    ] else
                      Text(widget.address,
                          style: AppTextStyles.body.copyWith(
                              fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.lat.toStringAsFixed(5)}, '
                      '${widget.lng.toStringAsFixed(5)}',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),

              if (_myLocation == null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _locating ? null : _goToMyLocation,
                    icon: _locating
                        ? const SizedBox(width: 14, height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.sage))
                        : const Icon(Icons.my_location_rounded,
                            size: 16, color: AppColors.sage),
                    label: Text(
                      _locating
                          ? 'Getting location…'
                          : 'Show My Location & Distance',
                      style: const TextStyle(
                          color: AppColors.sage,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.sage),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Address row widget ────────────────────────────────────────────────────────
class _AddrRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AddrRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 13, color: AppColors.ink3),
        const SizedBox(width: 6),
        Expanded(child: Text(text,
            style: AppTextStyles.body.copyWith(
                fontSize: 12.5, color: AppColors.ink2))),
      ]),
    );
  }
}

// ── Control button ────────────────────────────────────────────────────────────
class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String? tooltip;
  const _ControlBtn({
    required this.icon,
    required this.onTap,
    this.color = AppColors.ink2,
    this.tooltip,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(
              color: Colors.black.withAlpha(31),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// ── Pin tail painter ──────────────────────────────────────────────────────────
class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_) => false;
}
