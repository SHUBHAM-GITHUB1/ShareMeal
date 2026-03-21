import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sharemeal/models/app_state.dart';
import 'package:sharemeal/models/food_post.dart';
import 'package:sharemeal/constants/app_theme.dart';
import 'package:sharemeal/screens/login_screen.dart';
import 'package:sharemeal/constants/app_responsive.dart';
import 'package:sharemeal/services/meal_service.dart';
import 'package:sharemeal/services/notification_service.dart';
import 'package:sharemeal/services/local_notification_service.dart';
import 'package:sharemeal/screens/pickup_map_screen.dart';
import 'package:sharemeal/services/widgets/expiry_timer_widget.dart';

class NGODashboard extends StatefulWidget {
  const NGODashboard({super.key});
  @override
  State<NGODashboard> createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard>
    with SingleTickerProviderStateMixin {
  final _notifService = NotificationService();
  final Set<String> _seenIds = {};
  late final TabController _tabCtrl;
  Position? _myPosition;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _saveNgoLocation();
    _listenForNewNotifications();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _listenForNewNotifications() {
    _notifService.streamMyNotifications().listen((notifications) {
      for (final n in notifications) {
        if (!n.read && !_seenIds.contains(n.id)) {
          _seenIds.add(n.id);
          LocalNotificationService.showFoodNotification(
            id:         n.id.hashCode,
            donorName:  n.donorName,
            item:       n.item,
            qty:        n.qty,
            distanceKm: n.distanceKm,
          );
        }
      }
    });
  }

  Future<void> _saveNgoLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _myPosition = pos);
      await NotificationService().saveMyLocation(pos.latitude, pos.longitude);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final appState = Provider.of<AppState>(context);
    final user     = appState.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _SharedAppBar(
        title: 'NGO Live Feed',
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'My Pickups'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppDecorations.liveBadge,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 5, height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.amberLt,
                  boxShadow: [BoxShadow(color: AppColors.amber, blurRadius: 5)],
                ),
              ),
              const SizedBox(width: 5),
              const Text('LIVE', style: AppTextStyles.liveLabel),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () {
              setState(() {});
              _snack(context, '✓ Feed refreshed', AppColors.sage);
            },
          ),
        ],
      ),
      drawer: _SharedDrawer(user: user, appState: appState),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── Available tab ──
          StreamBuilder<List<FoodPost>>(
            stream: MealService().streamAvailableMeals(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.sage));
              }
              final posts = snap.data ?? [];
              return posts.isEmpty
                  ? const _EmptyState(isDonor: false)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      itemCount: posts.length,
                      itemBuilder: (_, i) => _FoodCard(
                        post: posts[i],
                        index: i,
                        myPosition: _myPosition,
                      ),
                    );
            },
          ),
          // ── My Pickups tab ──
          StreamBuilder<List<FoodPost>>(
            stream: MealService().streamMyClaimedMeals(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.sage));
              }
              final posts = snap.data ?? [];
              return posts.isEmpty
                  ? const _EmptyTabState(message: 'No claimed food yet')
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      itemCount: posts.length,
                      itemBuilder: (_, i) => _ClaimedFoodCard(post: posts[i]),
                    );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Food Card ────────────────────────────────────────────────────────────────
class _FoodCard extends StatelessWidget {
  final FoodPost post;
  final int index;
  final Position? myPosition;
  const _FoodCard({required this.post, required this.index, this.myPosition});

  String _distanceLabel() {
    if (myPosition == null || !post.hasLocation) return '— km';
    final distMeters = Geolocator.distanceBetween(
      myPosition!.latitude, myPosition!.longitude,
      post.lat!, post.lng!,
    );
    final km = distMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    final sageBg     = ThemeHelper.sageBg(context);

    return Container(
      margin: EdgeInsets.only(bottom: AppResponsive.h(16)),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Image with badges
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Stack(children: [
            _FoodImage(img: post.img, isBase64: post.imgIsBase64, height: 170),
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (post.isVeg ? AppColors.sage : AppColors.terr).withAlpha(224),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  const SizedBox(width: 5),
                  Text(post.isVeg ? 'Veg' : 'Non-Veg',
                      style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    post.hasLocation ? Icons.location_on_rounded : Icons.location_off_outlined,
                    size: 11, color: AppColors.amberLt,
                  ),
                  const SizedBox(width: 3),
                  Text(_distanceLabel(), style: const TextStyle(fontSize: 10.5,
                      color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        ),

        // Card body
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Title + qty badge
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(post.item,
                  style: AppTextStyles.sectionHead.copyWith(fontSize: 18, color: textColor),
                  overflow: TextOverflow.ellipsis, maxLines: 1)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.amber.withAlpha(31),
                  border: Border.all(color: AppColors.amber.withAlpha(77)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(post.qty,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.amberDk)),
              ),
            ]),
            const SizedBox(height: 8),

            // Donor + time
            Row(children: [
              Icon(Icons.business_outlined, size: 13, color: mutedColor),
              const SizedBox(width: 4),
              Expanded(child: Text(post.donor, style: AppTextStyles.bodySmall.copyWith(color: mutedColor),
                  overflow: TextOverflow.ellipsis)),
              Icon(Icons.access_time_rounded, size: 13, color: mutedColor),
              const SizedBox(width: 4),
              Text(DateFormat('hh:mm a').format(post.time),
                  style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
            ]),

            // ⏰ Expiry time display
            if (post.expiryTime != null) ...[
              const SizedBox(height: 8),
              ExpiryTimestamp(expiryTime: post.expiryTime, showStatus: true),
            ],

            // Show warning if expiring soon or expired
            if (post.expiryTime != null && post.isExpiringSoon) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.warning_rounded, size: 14, color: Color(0xFFFF6B35)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Expires soon! Only ${post.remainingTimeFormatted} left',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFFF6B35)),
                    ),
                  ),
                ]),
              ),
            ],

            // Location chip
            if (post.locationAddress != null && post.locationAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: post.hasLocation
                    ? () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => PickupMapScreen(
                            lat: post.lat!, lng: post.lng!,
                            address: post.locationAddress!,
                            foodItem: post.item, donorName: post.donor,
                          ),
                        ))
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: sageBg, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.sage.withAlpha(51)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.location_on_rounded, size: 13, color: AppColors.sage),
                    const SizedBox(width: 6),
                    Expanded(child: Text(post.locationAddress!,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.sage, fontWeight: FontWeight.w600, fontSize: 11.5),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (post.hasLocation)
                      const Icon(Icons.map_outlined, size: 13, color: AppColors.sage),
                  ]),
                ),
              ),
            ],

            // Nutrient chips
            if (post.nutrients != null) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _NutrientChip('Cal',     post.nutrients!.caloriesStr, Colors.deepOrange),
                _NutrientChip('Protein', post.nutrients!.proteinStr,  const Color(0xFF5B8DEF)),
                _NutrientChip('Carbs',   post.nutrients!.carbsStr,    AppColors.amber),
                _NutrientChip('Fat',     post.nutrients!.fatStr,      AppColors.terr),
              ]),
            ],

            const SizedBox(height: 14),

            // Claim button
            SizedBox(
              width: double.infinity, height: 52,
              child: GestureDetector(
                onTap: () => _showDetails(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.sageButton,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    boxShadow: [BoxShadow(
                        color: AppColors.sage.withAlpha(71), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  alignment: Alignment.center,
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('CLAIM FOOD', style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 13, letterSpacing: 1.2)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showDetails(BuildContext context) {
    final dialogBg   = ThemeHelper.sheetColor(context);
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    final sageBg     = ThemeHelper.sageBg(context);
    final nutBoxBg   = ThemeHelper.cardColor(context);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
        backgroundColor: dialogBg,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Header
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(gradient: AppGradients.sageButton, borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.fastfood_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.item, style: AppTextStyles.sectionHead.copyWith(color: textColor),
                    overflow: TextOverflow.ellipsis),
                Text('From: ${post.donor}', style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
              ])),
            ]),

            // Donor contact
            if (post.donorPhone.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B8DEF).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5B8DEF).withAlpha(56)),
                ),
                child: Row(children: [
                  const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF5B8DEF)),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Contact Donor: ${post.donorPhone}',
                      style: AppTextStyles.bodySmall.copyWith(color: textColor),
                      overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ],

            // ⏰ Expiry information
            if (post.expiryTime != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: post.isExpired
                    ? const Color(0xFFE07856).withAlpha(20)
                    : const Color(0xFF6B9080).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: post.isExpired
                      ? const Color(0xFFE07856).withAlpha(56)
                      : const Color(0xFF6B9080).withAlpha(56),
                  ),
                ),
                child: Row(children: [
                  Icon(
                    post.isExpired ? Icons.error_outline : Icons.schedule_rounded,
                    size: 15,
                    color: post.isExpired ? const Color(0xFFE07856) : const Color(0xFF6B9080),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(
                    'Expires: ${post.isExpired ? 'EXPIRED' : post.remainingTimeFormatted}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: post.isExpired ? const Color(0xFFE07856) : const Color(0xFF6B9080),
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
                ]),
              ),
            ],

            // Nutrition facts
            if (post.nutrients != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sageBg, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sage.withAlpha(51)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.local_dining_outlined, color: AppColors.sage, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Nutrition Facts',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.sage))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: post.nutrients!.source == 'api'
                            ? Colors.green.withAlpha(38) : Colors.orange.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post.nutrients!.source == 'api' ? 'Live API' : 'Estimated',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: post.nutrients!.source == 'api' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: _NutrientBox('Cal', post.nutrients!.caloriesStr, Colors.deepOrange, nutBoxBg)),
                    const SizedBox(width: 8),
                    Expanded(child: _NutrientBox('Protein', post.nutrients!.proteinStr, const Color(0xFF5B8DEF), nutBoxBg)),
                  ])),
                  const SizedBox(height: 8),
                  IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: _NutrientBox('Carbs', post.nutrients!.carbsStr, AppColors.amber, nutBoxBg)),
                    const SizedBox(width: 8),
                    Expanded(child: _NutrientBox('Fat', post.nutrients!.fatStr, AppColors.terr, nutBoxBg)),
                  ])),
                  const SizedBox(height: 10),
                  _InfoRow('Fiber',       post.nutrients!.fiberStr,       textColor, mutedColor),
                  _InfoRow('Sugar',       post.nutrients!.sugarStr,       textColor, mutedColor),
                  _InfoRow('Sodium',      post.nutrients!.sodiumStr,      textColor, mutedColor),
                  _InfoRow('Cholesterol', post.nutrients!.cholesterolStr, textColor, mutedColor),
                  if (post.nutrients!.servingSize > 0)
                    _InfoRow('Serving', post.nutrients!.servingSizeStr, textColor, mutedColor),
                ]),
              ),
            ],

            const SizedBox(height: 14),

            // Pickup address
            if (post.locationAddress != null && post.locationAddress!.isNotEmpty) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: sageBg, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.sage.withAlpha(51)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.sage, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Pickup Address', style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.sage, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(post.locationAddress!, style: AppTextStyles.body.copyWith(fontSize: 13, color: textColor)),
                  ])),
                ]),
              ),
              if (post.hasLocation) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PickupMapScreen(
                          lat: post.lat!, lng: post.lng!,
                          address: post.locationAddress!,
                          foodItem: post.item, donorName: post.donor,
                        ),
                      ));
                    },
                    icon: const Icon(Icons.map_outlined, size: 16, color: AppColors.sage),
                    label: const Text('View Pickup on Map',
                        style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.sage),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
            ],

            // Info notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withAlpha(20), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amber.withAlpha(56)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.amberDk),
                SizedBox(width: 8),
                Expanded(child: Text('Donor will be notified when you confirm pickup',
                    style: TextStyle(fontSize: 11.5, color: AppColors.amberDk))),
              ]),
            ),

            const SizedBox(height: 20),

            // ── FIX: Both buttons use IntrinsicHeight + symmetric padding ──
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: ThemeHelper.dividerColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                    child: const Text('Close',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () { Navigator.pop(ctx); _confirmClaim(context); },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sageButton,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: [BoxShadow(
                            color: AppColors.sage.withAlpha(71), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      alignment: Alignment.center,
                      child: const Text('Claim Food',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmClaim(BuildContext context) {
    final dialogBg   = ThemeHelper.sheetColor(context);
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    final sageBg     = ThemeHelper.sageBg(context);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: dialogBg,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: AppGradients.sageButton, shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: AppColors.sage.withAlpha(77), blurRadius: 16, offset: const Offset(0, 5))],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Confirm Claim', style: AppTextStyles.sectionHead.copyWith(color: textColor)),
            const SizedBox(height: 6),
            Text('You are claiming:', style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sageBg, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sage.withAlpha(51)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.item, style: AppTextStyles.body.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 4),
                Text('Qty: ${post.qty}  •  From: ${post.donor}',
                    style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
              ]),
            ),
            const SizedBox(height: 20),

            // ── FIX: Both buttons use IntrinsicHeight + symmetric padding ──
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: ThemeHelper.dividerColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await MealService().claimMeal(post.id);
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        _snack(context, '✅ Food claimed! Donor has been notified', AppColors.sage);
                      } catch (e) {
                        if (!context.mounted) return;
                        _snack(context, 'Error: $e', AppColors.terr);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sageButton,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: [BoxShadow(
                            color: AppColors.sage.withAlpha(71), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      alignment: Alignment.center,
                      child: const Text('Confirm Pickup',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Shared AppBar ────────────────────────────────────────────────────────────
class _SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final TabBar? bottom;
  const _SharedAppBar({required this.title, this.actions = const [], this.bottom});

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom != null ? kTextTabBarHeight : 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.sageHero,
      foregroundColor: Colors.white,
      elevation: 0, titleSpacing: 0, bottom: bottom,
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppGradients.heroBar)),
      title: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: AppGradients.amberBadge,
            boxShadow: [BoxShadow(
                color: AppColors.amber.withAlpha(89), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.favorite, size: 20, color: Colors.white.withAlpha(242)),
            const Icon(Icons.handshake, size: 11, color: Color(0xFF92400E)),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700,
                fontSize: 17, letterSpacing: -0.2), overflow: TextOverflow.ellipsis),
            const Text('ShareMeal', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400,
                color: Color(0xCCFFFFFF), letterSpacing: 1.5), overflow: TextOverflow.ellipsis),
          ],
        )),
      ]),
      actions: actions,
    );
  }
}

// ─── Shared Drawer ────────────────────────────────────────────────────────────
class _SharedDrawer extends StatelessWidget {
  final dynamic user;
  final AppState appState;
  const _SharedDrawer({required this.user, required this.appState});

  @override
  Widget build(BuildContext context) {
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    final drawerBg   = ThemeHelper.sheetColor(context);

    return Drawer(
      backgroundColor: drawerBg,
      child: Column(children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.heroBar),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle, gradient: AppGradients.amberBadge,
                boxShadow: [BoxShadow(
                    color: AppColors.amber.withAlpha(89), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Stack(alignment: Alignment.center, children: [
                Icon(Icons.favorite, size: 30, color: Colors.white.withAlpha(242)),
                const Icon(Icons.handshake, size: 15, color: Color(0xFF92400E)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.orgName ?? 'Guest',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                      fontSize: 16, fontFamily: 'Georgia'),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(user?.email ?? '—',
                  style: TextStyle(color: Colors.white.withAlpha(191), fontSize: 12.5),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: AppDecorations.liveBadge,
                child: Text(user?.role ?? 'User',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.amberLt, letterSpacing: 0.8)),
              ),
            ])),
          ]),
        ),

        const SizedBox(height: 10),
        _DrawerItem(
          icon: Icons.location_on_outlined, title: 'My Address',
          subtitle: (user?.address?.trim().isNotEmpty == true) ? user!.address : 'Not set',
          color: AppColors.sage, textColor: textColor, mutedColor: mutedColor,
        ),
        Divider(color: ThemeHelper.dividerColor(context), indent: 20, endIndent: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.amber.withAlpha(26), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.history_rounded, color: AppColors.amber, size: 18),
            ),
            title: Text('Pickup History',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: textColor)),
            trailing: Icon(Icons.chevron_right_rounded, size: 18, color: mutedColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context, isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const _PickupHistorySheet(),
              );
            },
          ),
        ),
        Divider(color: ThemeHelper.dividerColor(context), indent: 20, endIndent: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SwitchListTile(
            secondary: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.sage.withAlpha(26), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.dark_mode_outlined, color: AppColors.sage, size: 18),
            ),
            title: Text('Dark Mode',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: textColor)),
            value: appState.isDarkMode,
            activeThumbColor: AppColors.sage,
            onChanged: (_) => appState.toggleTheme(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const Spacer(),
        Divider(color: ThemeHelper.dividerColor(context), indent: 20, endIndent: 20),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.terr.withAlpha(26), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.logout_rounded, color: AppColors.terr, size: 18),
            ),
            title: Text('Logout',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.terr)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () async {
              await appState.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false,
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─── Pickup History Sheet ─────────────────────────────────────────────────────
class _PickupHistorySheet extends StatelessWidget {
  const _PickupHistorySheet();

  @override
  Widget build(BuildContext context) {
    final sheetBg    = ThemeHelper.sheetColor(context);
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.82, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: ThemeHelper.dividerColor(context), borderRadius: BorderRadius.circular(4)),
              )),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.amber.withAlpha(31), borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.history_rounded, color: AppColors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pickup History',
                      style: AppTextStyles.cardHead.copyWith(fontSize: 17, color: textColor)),
                  Text('Food you have collected',
                      style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
                ])),
              ]),
              const SizedBox(height: 12),
              Divider(color: ThemeHelper.dividerColor(context)),
            ]),
          ),
          Expanded(
            child: StreamBuilder<List<HistoryEntry>>(
              stream: MealService().streamPickupHistory(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.sage));
                }
                final entries = snap.data ?? [];
                if (entries.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 72, height: 72,
                        decoration: BoxDecoration(
                            color: AppColors.amber.withAlpha(26), shape: BoxShape.circle),
                        child: const Icon(Icons.inventory_2_outlined, size: 34, color: AppColors.amber)),
                    const SizedBox(height: 14),
                    Text('No pickups yet',
                        style: AppTextStyles.sectionHead.copyWith(color: textColor)),
                    const SizedBox(height: 6),
                    Text('Confirmed pickups will appear here',
                        style: AppTextStyles.bodyMuted.copyWith(color: mutedColor)),
                  ]));
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  itemCount: entries.length,
                  itemBuilder: (_, i) => _HistoryCard(
                    entry: entries[i],
                    partnerLabel: 'Donated by',
                    accentColor: AppColors.amber,
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDonor;
  const _EmptyState({required this.isDonor});
  @override
  Widget build(BuildContext context) {
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.sage.withAlpha(31), AppColors.sageMid.withAlpha(46)]),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.sage.withAlpha(51), width: 1.5),
        ),
        child: Icon(isDonor ? Icons.restaurant_outlined : Icons.search_off_rounded,
            size: 44, color: AppColors.sage),
      ),
      const SizedBox(height: 20),
      Text(isDonor ? 'No posts yet' : 'No food available',
          style: AppTextStyles.sectionHead.copyWith(color: textColor)),
      const SizedBox(height: 8),
      Text(
        isDonor ? 'Tap + to broadcast your first donation' : 'Check back later for donations',
        style: AppTextStyles.bodyMuted.copyWith(color: mutedColor),
      ),
    ]));
  }
}

// ─── Empty Tab State ──────────────────────────────────────────────────────────
class _EmptyTabState extends StatelessWidget {
  final String message;
  const _EmptyTabState({required this.message});
  @override
  Widget build(BuildContext context) => Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.amber.withAlpha(31), shape: BoxShape.circle),
            child: const Icon(Icons.inbox_outlined, size: 38, color: AppColors.amber)),
        const SizedBox(height: 16),
        Text(message, style: AppTextStyles.sectionHead.copyWith(color: ThemeHelper.onSurface(context))),
      ]));
}

// ─── Claimed Food Card ────────────────────────────────────────────────────────
class _ClaimedFoodCard extends StatelessWidget {
  final FoodPost post;
  const _ClaimedFoodCard({required this.post});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    final sageBg     = ThemeHelper.sageBg(context);

    return Container(
      margin: EdgeInsets.only(bottom: AppResponsive.h(16)),
      decoration: ThemeHelper.cardDecoration(context, accentLeft: AppColors.amber),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(post.item,
                style: AppTextStyles.sectionHead.copyWith(fontSize: 16, color: textColor),
                overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amber.withAlpha(31), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.amber.withAlpha(77)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.directions_bike_outlined, size: 10, color: AppColors.amberDk),
                SizedBox(width: 4),
                Text('Claimed', style: TextStyle(
                    fontSize: 10.5, color: AppColors.amberDk, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.business_outlined, size: 13, color: mutedColor),
            const SizedBox(width: 4),
            Expanded(child: Text('From: ${post.donor}',
                style: AppTextStyles.bodySmall.copyWith(color: mutedColor),
                overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Icon(Icons.scale_outlined, size: 13, color: mutedColor),
            const SizedBox(width: 4),
            Text(post.qty, style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
          ]),
          if (post.donorPhone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B8DEF).withAlpha(20), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF5B8DEF).withAlpha(56)),
              ),
              child: Row(children: [
                const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF5B8DEF)),
                const SizedBox(width: 8),
                Flexible(child: Text('Contact Donor: ${post.donorPhone}',
                    style: AppTextStyles.bodySmall.copyWith(color: textColor),
                    overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ],
          if (post.locationAddress != null && post.locationAddress!.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: post.hasLocation
                  ? () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PickupMapScreen(
                          lat: post.lat!, lng: post.lng!,
                          address: post.locationAddress!,
                          foodItem: post.item, donorName: post.donor,
                        ),
                      ))
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: sageBg, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.sage.withAlpha(51)),
                ),
                child: Row(children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: AppColors.sage),
                  const SizedBox(width: 6),
                  Expanded(child: Text(post.locationAddress!,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.sage, fontWeight: FontWeight.w600, fontSize: 11.5),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (post.hasLocation)
                    const Icon(Icons.map_outlined, size: 13, color: AppColors.sage),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber.withAlpha(20), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.amber.withAlpha(56)),
            ),
            child: const Row(children: [
              Icon(Icons.directions_bike_outlined, size: 15, color: AppColors.amberDk),
              SizedBox(width: 8),
              Expanded(child: Text('Claimed! Head to the pickup location to collect',
                  style: TextStyle(fontSize: 12, color: AppColors.amberDk, fontWeight: FontWeight.w600))),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final String partnerLabel;
  final Color accentColor;
  const _HistoryCard({required this.entry, required this.partnerLabel, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final textColor  = ThemeHelper.onSurface(context);
    final mutedColor = ThemeHelper.onSurfaceMuted(context);
    final vegColor   = entry.isVeg ? AppColors.sage : AppColors.terr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ThemeHelper.cardDecoration(context, accentLeft: accentColor),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(width: 60, height: 60, color: AppColors.sageBg,
                child: const Center(child: Icon(Icons.fastfood_outlined, size: 28, color: AppColors.sage))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(entry.item,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14.5, color: textColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(26), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withAlpha(56)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle_rounded, size: 10, color: accentColor),
                  const SizedBox(width: 4),
                  Text('Done', style: TextStyle(
                      fontSize: 10, color: accentColor, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.scale_outlined, size: 12, color: mutedColor),
              const SizedBox(width: 4),
              Text(entry.qty, style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
              const SizedBox(width: 10),
              Container(width: 6, height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: vegColor)),
              const SizedBox(width: 4),
              Text(entry.isVeg ? 'Veg' : 'Non-Veg',
                  style: TextStyle(fontSize: 11, color: vegColor, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.handshake_outlined, size: 12, color: mutedColor),
              const SizedBox(width: 4),
              Expanded(child: Text('$partnerLabel: ${entry.partnerName}',
                  style: AppTextStyles.bodySmall.copyWith(color: mutedColor, fontSize: 11.5),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.access_time_rounded, size: 12, color: mutedColor),
              const SizedBox(width: 4),
              Flexible(child: Text(DateFormat('dd MMM yyyy, hh:mm a').format(entry.completedAt),
                  style: AppTextStyles.bodySmall.copyWith(color: mutedColor, fontSize: 10.5),
                  overflow: TextOverflow.ellipsis)),
            ]),
          ])),
        ]),
      ),
    );
  }
}

// ─── Nutrient Box ─────────────────────────────────────────────────────────────
class _NutrientBox extends StatelessWidget {
  final String label, value;
  final Color color, bgColor;
  const _NutrientBox(this.label, this.value, this.color, this.bgColor);

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: AppResponsive.h(10), horizontal: AppResponsive.w(12)),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(56)),
      ),
      child: Row(mainAxisSize: MainAxisSize.max, children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Flexible(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10, fontWeight: FontWeight.w500,
                  color: ThemeHelper.onSurfaceMuted(context)),
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color textColor, mutedColor;
  const _InfoRow(this.label, this.value, this.textColor, this.mutedColor);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
        const Spacer(),
        Text(value, style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600, color: textColor)),
      ]),
    );
  }
}

// ─── Nutrient Chip ────────────────────────────────────────────────────────────
class _NutrientChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _NutrientChip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final iconSize   = AppResponsive.isLarge ? 6.0 : AppResponsive.r(8).toDouble();
    final iconRadius = AppResponsive.isLarge ? 1.5 : AppResponsive.r(2).toDouble();
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(10), vertical: AppResponsive.h(5)),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppResponsive.r(20)),
        border: Border.all(color: color.withAlpha(56)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: iconSize, height: iconSize,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(iconRadius))),
        SizedBox(width: AppResponsive.w(6)),
        Flexible(child: Text('$label · $value', style: TextStyle(
            fontSize: AppResponsive.sp(11.5), fontWeight: FontWeight.w600,
            color: color.withAlpha(217)), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

// ─── Drawer Item ──────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color, textColor, mutedColor;
  const _DrawerItem({
    required this.icon, required this.title, this.subtitle,
    required this.color, required this.textColor, required this.mutedColor,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Container(width: 36, height: 36,
            decoration: BoxDecoration(
                color: color.withAlpha(26), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
        title: Text(title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: textColor)),
        subtitle: (subtitle != null && subtitle!.trim().isNotEmpty)
            ? Text(subtitle!, style: AppTextStyles.bodySmall.copyWith(color: mutedColor),
                maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ─── Food Image ───────────────────────────────────────────────────────────────
class _FoodImage extends StatelessWidget {
  final String img;
  final bool isBase64;
  final double height;
  const _FoodImage({required this.img, required this.isBase64, this.height = 170});

  @override
  Widget build(BuildContext context) {
    if (isBase64 && img.isNotEmpty) {
      return Image.memory(base64Decode(img), height: height, width: double.infinity,
          fit: BoxFit.cover, errorBuilder: (_, e, s) => _placeholder());
    }
    return Image.network(img, height: height, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _placeholder(),
        loadingBuilder: (_, child, progress) => progress == null ? child
            : Container(height: height, color: AppColors.sageBg,
                child: const Center(child: CircularProgressIndicator(
                    color: AppColors.sage, strokeWidth: 2))));
  }

  Widget _placeholder() => Container(
      height: height, color: AppColors.sageBg,
      child: const Center(child: Icon(Icons.fastfood_outlined, size: 52, color: AppColors.sage)));
}

void _snack(BuildContext context, String msg, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  ));
}