import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharemeal/constants/app_theme.dart';

class PickedLocation {
  final LatLng latLng;
  final String address;
  const PickedLocation({required this.latLng, required this.address});
}

class MapPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const MapPickerScreen({super.key, this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapCtrl;
  final _searchCtrl = TextEditingController();

  LatLng _picked = const LatLng(20.5937, 78.9629);

  String _street      = '';
  String _area        = '';
  String _city        = '';
  String _pincode     = '';
  String _state       = '';
  String _country     = '';
  String _fullAddress = 'Tap the map to pick a location';

  bool _loading  = false;
  bool _locating = false;
  bool _searched = false;
  List<Map<String, dynamic>> _searchResults = [];

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
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _loading = true);
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&addressdetails=1');
      final response = await http.get(url, headers: {'User-Agent': 'ShareMeal/1.0'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null) {
          final addr = data['address'];
          _street  = _clean(addr['house_number'] ?? '') + ' ' + _clean(addr['road'] ?? '');
          _area    = _clean(addr['suburb'] ?? addr['neighbourhood'] ?? '');
          _city    = _clean(addr['city'] ?? addr['town'] ?? addr['village'] ?? '');
          _pincode = _clean(addr['postcode'] ?? '');
          _state   = _clean(addr['state'] ?? '');
          _country = _clean(addr['country'] ?? '');

          final parts = <String>[
            if (_street.trim().isNotEmpty) _street.trim(),
            if (_area.isNotEmpty && _area != _city) _area,
            if (_city.isNotEmpty) _city,
            if (_pincode.isNotEmpty) _pincode,
            if (_state.isNotEmpty) _state,
            if (_country.isNotEmpty) _country,
          ];
          _fullAddress = parts.isNotEmpty
              ? parts.join(', ')
              : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        } else {
          _fullAddress = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        }
      } else {
        _fullAddress = 'Address resolution failed - coordinates: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      }
    } catch (_) {
      _street = _area = _city = _pincode = _state = _country = '';
      _fullAddress = 'Address resolution failed - coordinates: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _clean(String? s) => (s ?? '').trim();

  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _searched = true; _searchResults = []; });
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5');
      final response = await http.get(url, headers: {'User-Agent': 'ShareMeal/1.0'});
      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List;
        setState(() => _searchResults = results.cast<Map<String, dynamic>>());
      } else {
        setState(() => _searchResults = []);
      }
    } catch (_) {
      setState(() => _searchResults = []);
    }
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final ll = LatLng(lat, lon);
    _mapCtrl.move(ll, 15);
    setState(() { _picked = ll; _searchResults = []; _searched = false; });
    _searchCtrl.clear();
    FocusScope.of(context).unfocus();
    _reverseGeocode(ll);
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        _snack('Location permission denied. Enable in settings.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapCtrl.move(ll, 16);
      setState(() => _picked = ll);
      await _reverseGeocode(ll);
    } catch (e) {
      _snack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onTap(TapPosition _, LatLng pos) {
    setState(() { _picked = pos; _searchResults = []; _searched = false; });
    _reverseGeocode(pos);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: AppColors.terr,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad  = MediaQuery.of(context).padding.bottom;
    // Bottom card and search results always use theme-aware colors
    final cardBg     = ThemeHelper.sheetColor(context);
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    final fieldFill  = ThemeHelper.fieldFill(context);
    final divColor   = ThemeHelper.dividerColor(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            ),
            MarkerLayer(markers: [
              Marker(
                point: _picked, width: 48, height: 56,
                child: Column(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: AppGradients.sageButton, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.sage.withAlpha(115), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 18),
                  ),
                  CustomPaint(size: const Size(12, 8), painter: _PinTailPainter(AppColors.sage)),
                ]),
              ),
            ]),
          ],
        ),

        // ── Top bar + search ─────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.heroBar,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(38), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text('Pick Pickup Location',
                          style: TextStyle(color: Colors.white, fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 17)),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context,
                          PickedLocation(latLng: _picked, address: _fullAddress)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Confirm',
                            style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ]),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: fieldFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchPlace,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Search place, area or pincode…',
                        hintStyle: TextStyle(fontSize: 12.5, color: mutedColor),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.sage),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, size: 16, color: mutedColor),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() { _searchResults = []; _searched = false; });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),

        // ── Search results dropdown ───────────────────────────────────
        if (_searched)
          Positioned(
            top: 140, left: 12, right: 12,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: cardBg,
              child: _searchResults.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No results found', style: TextStyle(color: mutedColor)),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _searchResults.asMap().entries.map((e) {
                        final idx = e.key;
                        final loc = e.value;
                        return InkWell(
                          onTap: () => _selectSearchResult(loc),
                          borderRadius: BorderRadius.vertical(
                            top: idx == 0 ? const Radius.circular(12) : Radius.zero,
                            bottom: idx == _searchResults.length - 1 ? const Radius.circular(12) : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.sage),
                              const SizedBox(width: 10),
                              Expanded(child: Text(
                                loc['display_name'] ?? '${loc['lat']}, ${loc['lon']}',
                                style: TextStyle(fontSize: 12.5, color: textColor),
                              )),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),

        // ── Bottom address card ──────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(31), blurRadius: 20, offset: const Offset(0, -4))],
            ),
            padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: divColor, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),

              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.sage)),
                    const SizedBox(width: 10),
                    Text('Fetching address…', style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
                  ]),
                )
              else
                _AddressCard(
                  street: _street, area: _area, city: _city,
                  pincode: _pincode, state: _state, country: _country,
                  fullAddress: _fullAddress,
                  lat: _picked.latitude, lng: _picked.longitude,
                  cardBg: ThemeHelper.sageBg(context),
                  textColor: textColor, mutedColor: mutedColor,
                ),

              const SizedBox(height: 10),
              Text('Tap map to move pin  •  Search above to jump to a place',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: mutedColor, fontSize: 10.5)),
            ]),
          ),
        ),

        // ── My Location FAB ──────────────────────────────────────────
        Positioned(
          right: 16, bottom: 210,
          child: FloatingActionButton.small(
            heroTag: 'pickerLoc',
            backgroundColor: ThemeHelper.cardColor(context),
            elevation: 4,
            onPressed: _locating ? null : _goToMyLocation,
            child: _locating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.sage))
                : const Icon(Icons.my_location_rounded, color: AppColors.sage, size: 20),
          ),
        ),

        // ── Zoom controls ────────────────────────────────────────────
        Positioned(
          right: 16, bottom: 270,
          child: Column(children: [
            _ZoomBtn(icon: Icons.add, bgColor: ThemeHelper.cardColor(context), iconColor: ThemeHelper.onSurface(context),
                onTap: () { final c = _mapCtrl.camera; _mapCtrl.move(c.center, c.zoom + 1); }),
            const SizedBox(height: 4),
            _ZoomBtn(icon: Icons.remove, bgColor: ThemeHelper.cardColor(context), iconColor: ThemeHelper.onSurface(context),
                onTap: () { final c = _mapCtrl.camera; _mapCtrl.move(c.center, c.zoom - 1); }),
          ]),
        ),
      ]),
    );
  }
}

// ── Structured address card ───────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final String street, area, city, pincode, state, country, fullAddress;
  final double lat, lng;
  final Color cardBg, textColor, mutedColor;
  const _AddressCard({
    required this.street, required this.area, required this.city,
    required this.pincode, required this.state, required this.country,
    required this.fullAddress,
    required this.lat, required this.lng,
    required this.cardBg, required this.textColor, required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = city.isNotEmpty || state.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sage.withAlpha(51)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.sage.withAlpha(31), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.location_on_rounded, color: AppColors.sage, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Selected Location',
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.sage, fontSize: 11)),
          const SizedBox(height: 6),
          if (!hasData)
            Text('Tap the map to pick a location', style: AppTextStyles.bodySmall.copyWith(color: mutedColor))
          else ...[
            if (street.isNotEmpty)  _Row(Icons.signpost_outlined, street, mutedColor, textColor),
            if (area.isNotEmpty && area != city) _Row(Icons.holiday_village_outlined, area, mutedColor, textColor),
            if (city.isNotEmpty)    _Row(Icons.location_city_outlined, city, mutedColor, textColor),
            if (pincode.isNotEmpty) _Row(Icons.pin_drop_outlined, 'PIN: $pincode', mutedColor, textColor),
            if (state.isNotEmpty)   _Row(Icons.map_outlined, state, mutedColor, textColor),
            if (country.isNotEmpty) _Row(Icons.flag_outlined, country, mutedColor, textColor),
          ],
          const SizedBox(height: 4),
          Text(fullAddress,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: mutedColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color mutedColor, textColor;
  const _Row(this.icon, this.text, this.mutedColor, this.textColor);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 12, color: mutedColor),
        const SizedBox(width: 5),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall.copyWith(fontSize: 12, color: textColor))),
      ]),
    );
  }
}

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

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor, iconColor;
  const _ZoomBtn({required this.icon, required this.onTap, required this.bgColor, required this.iconColor});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(31), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}