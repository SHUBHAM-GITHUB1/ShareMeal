import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sharemeal/models/food_post.dart';
import 'package:sharemeal/models/history_entry.dart';
import 'package:sharemeal/models/app_state.dart';
import 'package:sharemeal/constants/app_theme.dart';
import 'package:sharemeal/screens/auth_wrapper.dart';
import 'package:sharemeal/constants/app_responsive.dart';
import 'package:sharemeal/screens/map_picker_screen.dart';
import 'package:sharemeal/services/meal_service.dart';
import 'package:sharemeal/services/image_service.dart';
import 'package:sharemeal/services/ai_food_service.dart';


class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});
  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard>
    with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _itemCtrl = TextEditingController();
  final _qtyCtrl  = TextEditingController();
  bool _isVeg        = true;
  bool _isAiLoading  = false;
  bool _isPosting    = false;
  String? _pickedImageB64;
  PickedLocation? _pickedLocation;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _itemCtrl.dispose();
    _qtyCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  String _fmt(String t) =>
      t.isEmpty ? t : t[0].toUpperCase() + t.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final appState = Provider.of<AppState>(context);
    final user     = appState.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _SharedAppBar(
        title: 'Donor Portal',
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
<<<<<<< HEAD
          tabs: const [Tab(text: 'Active'), Tab(text: 'Pending Approval')],
=======
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Pending Approval'),
          ],
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () {
              setState(() {});
              _snack(context, '✓ Refreshed', AppColors.sage);
            },
          ),
        ],
      ),
      drawer: _SharedDrawer(user: user, appState: appState),
      body: StreamBuilder<List<FoodPost>>(
        stream: MealService().streamMyMeals(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
<<<<<<< HEAD
          final all     = snap.data ?? [];
=======
          final all = snap.data ?? [];
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
          final active  = all.where((p) => p.status == 'available').toList();
          final pending = all.where((p) => p.status == 'picked_up' || p.status == 'claimed').toList();
          return TabBarView(
            controller: _tabCtrl,
            children: [
              active.isEmpty
                  ? const _EmptyState(isDonor: true)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                      itemCount: active.length,
                      itemBuilder: (_, i) => _DonorPostCard(post: active[i], index: i),
                    ),
              pending.isEmpty
                  ? const _EmptyTabState(message: 'No pending pickups')
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      itemCount: pending.length,
                      itemBuilder: (_, i) => _DonorPostCard(post: pending[i], index: i),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: _GradientFAB(
        onPressed: () => _showForm(context, user?.orgName ?? 'Anonymous'),
      ),
    );
  }

  // ── Post Surplus bottom sheet ─────────────────────────────────────
  void _showForm(BuildContext context, String donorName) {
    setState(() {
      _isVeg = true;
      _isPosting = false;
      _pickedImageB64 = null;
      _pickedLocation = null;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setModal) {
          // Read theme once inside builder so it reflects the app's current theme
          final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
          final surfaceColor = AppThemeColors.surface(sheetCtx);
          final onSurface    = AppThemeColors.onSurface(sheetCtx);
          final mutedColor   = AppThemeColors.onSurfaceMuted(sheetCtx);
          final divColor     = AppThemeColors.divider(sheetCtx);

          return Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppResponsive.h(24),
              left: AppResponsive.w(24), right: AppResponsive.w(24), top: AppResponsive.h(8),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      decoration: BoxDecoration(color: divColor, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  // Header
                  Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        gradient: AppGradients.sageButton,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [BoxShadow(color: AppColors.sage.withAlpha(64), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.broadcast_on_personal_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Broadcast Donation',
                          style: AppTextStyles.cardHead.copyWith(fontSize: 17, fontStyle: FontStyle.normal, color: onSurface)),
                      Text('Notify nearby NGOs instantly',
                          style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
                    ])),
                  ]),
                  const SizedBox(height: 24),

                  // Food Item
                  Text('FOOD ITEM', style: AppTextStyles.fieldLabel.copyWith(color: mutedColor)),
                  const SizedBox(height: 6),
                  _SheetField(
                    controller: _itemCtrl,
                    hint: 'e.g. Rice, Bread, Fruits',
                    icon: Icons.fastfood_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 3) return 'Min 3 characters';
                      return null;
                    },
                  ),
                  if (_isAiLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(children: [
                        const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.sage)),
                        const SizedBox(width: 8),
                        Text('AI identifying food…',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.sage, fontSize: 11.5)),
                      ]),
                    ),
                  const SizedBox(height: 14),

                  // Quantity
                  Text('QUANTITY (KG)', style: AppTextStyles.fieldLabel.copyWith(color: mutedColor)),
                  const SizedBox(height: 6),
                  _SheetField(
                    controller: _qtyCtrl,
                    hint: 'e.g. 5',
                    icon: Icons.scale_outlined,
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Image Picker
                  Text('FOOD PHOTO', style: AppTextStyles.fieldLabel.copyWith(color: mutedColor)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showImageSourceSheet(sheetCtx, setModal),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppThemeColors.fieldBg(sheetCtx),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppThemeColors.fieldBorder(sheetCtx)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _pickedImageB64 != null
                          ? Stack(fit: StackFit.expand, children: [
                              Image.memory(base64Decode(_pickedImageB64!), fit: BoxFit.cover),
                              Positioned(
                                top: 6, right: 6,
                                child: GestureDetector(
                                  onTap: () => setModal(() => _pickedImageB64 = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ])
                          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 32, color: mutedColor),
                              const SizedBox(height: 6),
                              Text('Tap to add photo', style: AppTextStyles.bodySmall.copyWith(color: mutedColor)),
                              const SizedBox(height: 2),
                              Text('Or we\'ll fetch one automatically',
                                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10.5, color: mutedColor)),
                            ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Picker
                  Text('PICKUP LOCATION', style: AppTextStyles.fieldLabel.copyWith(color: mutedColor)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<PickedLocation>(
                        sheetCtx,
                        MaterialPageRoute(builder: (_) => MapPickerScreen(initial: _pickedLocation?.latLng)),
                      );
                      if (result != null) {
                        setState(() => _pickedLocation = result);
                        setModal(() => _pickedLocation = result);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppThemeColors.fieldBg(sheetCtx),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _pickedLocation != null ? AppColors.sage : AppThemeColors.fieldBorder(sheetCtx),
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: _pickedLocation != null
                                ? AppColors.sage.withAlpha(31)
                                : AppThemeColors.fieldBorder(sheetCtx).withAlpha(77),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            _pickedLocation != null ? Icons.location_on_rounded : Icons.add_location_alt_outlined,
                            color: _pickedLocation != null ? AppColors.sage : mutedColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _pickedLocation != null
                              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Location set',
                                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.sage, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(_pickedLocation!.address,
                                      style: AppTextStyles.bodySmall.copyWith(color: mutedColor, fontSize: 11.5),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                ])
                              : Text('Tap to set pickup location on map',
                                  style: AppTextStyles.bodySmall.copyWith(fontSize: 13, color: mutedColor)),
                        ),
                        Icon(Icons.chevron_right_rounded, color: mutedColor, size: 20),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Veg toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppThemeColors.fieldBg(sheetCtx),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppThemeColors.fieldBorder(sheetCtx)),
                    ),
                    child: Row(children: [
                      Text('Food Type', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: onSurface)),
                      const SizedBox(width: 16),
                      _VegToggle(label: '🟢  Veg',     value: true,  group: _isVeg, color: AppColors.sage, onChanged: (v) => setModal(() => _isVeg = v!)),
                      const SizedBox(width: 12),
                      _VegToggle(label: '🔴  Non-Veg', value: false, group: _isVeg, color: AppColors.terr, onChanged: (v) => setModal(() => _isVeg = v!)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isPosting ? null : () => Navigator.pop(sheetCtx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFD0D8DC) : AppColors.ink2,
                          side: BorderSide(color: AppThemeColors.fieldBorder(sheetCtx)),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(double.infinity, AppResponsive.h(52)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppResponsive.r(AppDimensions.radiusMd))),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _GradientButton(
                        label: 'Post Donation',
                        isLoading: _isPosting,
                        onPressed: _isPosting ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setModal(() => _isPosting = true);
                            try {
                              await MealService().postMeal(
                                item: _fmt(_itemCtrl.text.trim()),
                                qty: _qtyCtrl.text.trim(),
                                isVeg: _isVeg,
                                donorName: donorName,
                                imageBase64: _pickedImageB64,
                                lat: _pickedLocation?.latLng.latitude,
                                lng: _pickedLocation?.latLng.longitude,
                                locationAddress: _pickedLocation?.address,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(sheetCtx);
                              _itemCtrl.clear(); _qtyCtrl.clear();
                              setState(() { _pickedImageB64 = null; _pickedLocation = null; });
                              _snack(context, '✅ Food posted successfully!', AppColors.sage);
                            } catch (e) {
                              if (!context.mounted) return;
                              setModal(() => _isPosting = false);
                              _snack(context, 'Error: $e', AppColors.terr);
                            }
                          }
                        },
                      ),
                    ),
                  ]),
                ]),
              ),
<<<<<<< HEAD
=======
              const SizedBox(height: 24),

              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isPosting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink2,
                      side: const BorderSide(color: AppColors.fieldBorder),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(double.infinity, AppResponsive.h(52)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppResponsive.r(AppDimensions.radiusMd))),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _GradientButton(
                    label: 'Post Donation',
                    isLoading: _isPosting,
                    onPressed: _isPosting ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setModal(() => _isPosting = true);
                        try {
                          await MealService().postMeal(
                            item:            _fmt(_itemCtrl.text.trim()),
                            qty:             _qtyCtrl.text.trim(),
                            isVeg:           _isVeg,
                            donorName:       donorName,
                            imageBase64:     _pickedImageB64,
                            lat:             _pickedLocation?.latLng.latitude,
                            lng:             _pickedLocation?.latLng.longitude,
                            locationAddress: _pickedLocation?.address,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _itemCtrl.clear();
                          _qtyCtrl.clear();
                          setState(() {
                            _pickedImageB64 = null;
                            _pickedLocation = null;
                          });
                          _snack(context, '✅ Food posted successfully!', AppColors.sage);
                        } catch (e) {
                          if (!context.mounted) return;
                          setModal(() => _isPosting = false);
                          _snack(context, 'Error: $e', AppColors.terr);
                        }
                      }
                    },
                  ),
                ),
              ]),
            ]),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, StateSetter setModal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: AppDecorations.bottomSheet(ctx),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppThemeColors.divider(ctx), borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.sage.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.photo_library_outlined, color: AppColors.sage),
              ),
              title: Text('Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppThemeColors.onSurface(ctx))),
              onTap: () async {
                Navigator.pop(ctx);
                final b64 = await ImageService.pickFromGallery();
                if (b64 != null) {
                  setState(() => _pickedImageB64 = b64);
                  setModal(() => _pickedImageB64 = b64);
                  _runAiIdentify(b64, setModal);
                }
              },
            ),
            ListTile(
              leading: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.sage.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.sage),
              ),
              title: Text('Take a Photo',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppThemeColors.onSurface(ctx))),
              onTap: () async {
                Navigator.pop(ctx);
                final b64 = await ImageService.pickFromCamera();
                if (b64 != null) {
                  setState(() => _pickedImageB64 = b64);
                  setModal(() => _pickedImageB64 = b64);
                  _runAiIdentify(b64, setModal);
                }
              },
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Future<void> _runAiIdentify(String b64, StateSetter setModal) async {
    setModal(() => _isAiLoading = true);
    final name = await AiFoodService.identifyFood(b64);
    if (name != null && mounted) _itemCtrl.text = name;
    setModal(() => _isAiLoading = false);
  }
}

// ─── Donor Post Card ──────────────────────────────────────────────────────────
class _DonorPostCard extends StatefulWidget {
  final FoodPost post;
  final int index;
  const _DonorPostCard({required this.post, required this.index});
  @override
  State<_DonorPostCard> createState() => _DonorPostCardState();
}

class _DonorPostCardState extends State<_DonorPostCard> {
  late FoodPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (_post.needsNutrientRefetch) _refetch();
  }

  @override
  void didUpdateWidget(_DonorPostCard old) {
    super.didUpdateWidget(old);
    if (widget.post.id != old.post.id ||
        (widget.post.needsNutrientRefetch && !old.post.needsNutrientRefetch)) {
      _post = widget.post;
      if (_post.needsNutrientRefetch) _refetch();
    }
  }

  Future<void> _refetch() async {
    final fresh = await _post.withFreshNutrients();
    if (mounted) setState(() => _post = fresh);
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
<<<<<<< HEAD
    final accent     = _post.isVeg ? AppColors.sage : AppColors.terr;
    final isClaimed  = _post.status == 'claimed';
    final isPickedUp = _post.status == 'picked_up';
    final isActive   = _post.status == 'available';
    final borderColor = isPickedUp ? AppColors.sage : isClaimed ? AppColors.amber : accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDecorations.cardAccentThemed(context, borderColor),
=======
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _post.isVeg ? AppColors.sage : AppColors.terr;
    final isClaimed   = _post.status == 'claimed';
    final isPickedUp  = _post.status == 'picked_up';
    final isActive    = _post.status == 'available';
    final borderColor = isPickedUp ? AppColors.sage
        : isClaimed ? AppColors.amber : accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F26) : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
        boxShadow: [
          BoxShadow(color: (isDark ? Colors.black : AppColors.ink).withAlpha(38),
              blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: (isDark ? Colors.black : AppColors.ink).withAlpha(20),
              blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(
            height: AppResponsive.h(140), width: double.infinity,
            child: _FoodImage(img: _post.img, isBase64: _post.imgIsBase64),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(_post.item,
<<<<<<< HEAD
                  style: AppTextStyles.bodyThemed(context).copyWith(fontWeight: FontWeight.w700, fontSize: 15.5))),
=======
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 15.5))),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
              if (isPickedUp) _PickedUpBadge()
              else if (isClaimed) _ClaimedBadge()
              else _StatusBadge(),
              if (isActive) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _deleteDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
<<<<<<< HEAD
                    decoration: BoxDecoration(color: AppColors.terr.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.terr),
=======
                    decoration: BoxDecoration(
                      color: AppColors.terr.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: AppColors.terr),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.scale_outlined, size: 13, color: AppColors.ink3),
              const SizedBox(width: 4),
<<<<<<< HEAD
              Text(_post.qty, style: AppTextStyles.bodySmallThemed(context).copyWith(color: AppThemeColors.onSurface2(context))),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.ink3),
              const SizedBox(width: 4),
              Text(DateFormat('hh:mm a').format(_post.time), style: AppTextStyles.bodySmallThemed(context)),
              const SizedBox(width: 12),
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
=======
              Text(_post.qty, style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink2)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.ink3),
              const SizedBox(width: 4),
              Text(DateFormat('hh:mm a').format(_post.time), style: AppTextStyles.bodySmall),
              const SizedBox(width: 12),
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
              const SizedBox(width: 4),
              Text(_post.isVeg ? 'Veg' : 'Non-Veg',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: accent)),
            ]),
            if (_post.nutrients != null) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _NutrientChip('Cal',     _post.nutrients!.caloriesStr, Colors.deepOrange),
                _NutrientChip('Protein', _post.nutrients!.proteinStr,  const Color(0xFF5B8DEF)),
                _NutrientChip('Carbs',   _post.nutrients!.carbsStr,    AppColors.amber),
                _NutrientChip('Fat',     _post.nutrients!.fatStr,      AppColors.terr),
              ]),
            ],
            if (_post.locationAddress != null && _post.locationAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
<<<<<<< HEAD
                decoration: AppDecorations.sageBgThemed(context),
=======
                decoration: BoxDecoration(
                  color: AppColors.sageBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.sage.withAlpha(51)),
                ),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                child: Row(children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: AppColors.sage),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_post.locationAddress!,
<<<<<<< HEAD
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.sage, fontWeight: FontWeight.w600, fontSize: 11.5),
=======
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.sage, fontWeight: FontWeight.w600, fontSize: 11.5),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ],
<<<<<<< HEAD
=======
            // ── Claimed: NGO on the way — donor marks food as handed over ──
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
            if (isClaimed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
<<<<<<< HEAD
                decoration: BoxDecoration(color: AppColors.amber.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.amber.withAlpha(64))),
=======
                decoration: BoxDecoration(
                  color: AppColors.amber.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.amber.withAlpha(64)),
                ),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                child: const Row(children: [
                  Icon(Icons.directions_bike_outlined, size: 15, color: AppColors.amberDk),
                  SizedBox(width: 8),
                  Expanded(child: Text('NGO has claimed — tap below once they collect the food',
<<<<<<< HEAD
                      style: TextStyle(fontSize: 12, color: AppColors.amberDk, fontWeight: FontWeight.w600))),
=======
                      style: TextStyle(fontSize: 12, color: AppColors.amberDk,
                          fontWeight: FontWeight.w600))),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                ]),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _markPickedUpDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
<<<<<<< HEAD
                    gradient: const LinearGradient(colors: [AppColors.amber, AppColors.amberDk]),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    boxShadow: [BoxShadow(color: AppColors.amber.withAlpha(89), blurRadius: 12, offset: const Offset(0, 4))],
=======
                    gradient: const LinearGradient(
                        colors: [AppColors.amber, AppColors.amberDk]),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    boxShadow: [BoxShadow(
                        color: AppColors.amber.withAlpha(89),
                        blurRadius: 12, offset: const Offset(0, 4))],
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
<<<<<<< HEAD
                    Text('MARK AS PICKED UP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.2)),
=======
                    Text('MARK AS PICKED UP', style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.2)),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                  ]),
                ),
              ),
            ],
<<<<<<< HEAD
=======

>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
          ]),
        ),
      ]),
    );
  }

<<<<<<< HEAD
=======
  // ── Delete Dialog ──────────────────────────────────────────────
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
  void _deleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
<<<<<<< HEAD
        backgroundColor: AppThemeColors.surface(ctx),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 56, height: 56,
                decoration: BoxDecoration(color: AppColors.terr.withAlpha(20), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.terr, size: 26)),
            const SizedBox(height: 14),
            Text('Delete Post', style: AppTextStyles.sectionHeadThemed(ctx)),
            const SizedBox(height: 6),
            Text('Remove "${_post.item}" from your donations?',
                style: AppTextStyles.bodySmallThemed(ctx), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: SizedBox(height: 48, child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeColors.onSurface2(ctx),
                  side: BorderSide(color: AppThemeColors.fieldBorder(ctx)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ))),
              const SizedBox(width: 12),
              Expanded(child: SizedBox(height: 48, child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await MealService().deleteMeal(_post.id);
                    if (!context.mounted) return;
                    _snack(context, '🗑️ Post deleted', AppColors.terr);
                  } catch (e) {
                    if (!context.mounted) return;
                    _snack(context, 'Error: $e', AppColors.terr);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.terr, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd))),
                child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
              ))),
=======
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.terr.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.terr, size: 26),
            ),
            const SizedBox(height: 14),
            const Text('Delete Post', style: AppTextStyles.sectionHead),
            const SizedBox(height: 6),
            Text('Remove "${_post.item}" from your donations?',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink2,
                      side: const BorderSide(color: AppColors.fieldBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await MealService().deleteMeal(_post.id);
                        if (!context.mounted) return;
                        _snack(context, '🗑️ Post deleted', AppColors.terr);
                      } catch (e) {
                        if (!context.mounted) return;
                        _snack(context, 'Error: $e', AppColors.terr);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terr,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                    child: const Text('Delete',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
            ]),
          ]),
        ),
      ),
    );
  }

<<<<<<< HEAD
=======
  // ── Mark as Picked Up Dialog ──────────────────────────────────
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
  void _markPickedUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
<<<<<<< HEAD
        backgroundColor: AppThemeColors.surface(ctx),
=======
        backgroundColor: AppColors.white,
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.amber, AppColors.amberDk]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.amber.withAlpha(89), blurRadius: 16, offset: const Offset(0, 5))],
              ),
<<<<<<< HEAD
              child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Mark as Picked Up', style: AppTextStyles.sectionHeadThemed(ctx)),
            const SizedBox(height: 6),
            Text('Confirm the NGO has physically collected:',
                style: AppTextStyles.bodySmallThemed(ctx), textAlign: TextAlign.center),
=======
              child: const Icon(Icons.inventory_2_outlined,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            const Text('Mark as Picked Up', style: AppTextStyles.sectionHead),
            const SizedBox(height: 6),
            const Text('Confirm the NGO has physically collected:',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: AppColors.amber.withAlpha(20), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.amber.withAlpha(56)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_post.item, style: AppTextStyles.bodyThemed(ctx).copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Qty: ${_post.qty}', style: AppTextStyles.bodySmallThemed(ctx)),
=======
                color: AppColors.amber.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.amber.withAlpha(56)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_post.item, style: AppTextStyles.body.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Qty: ${_post.qty}', style: AppTextStyles.bodySmall),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
<<<<<<< HEAD
              Expanded(child: SizedBox(height: 52, child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeColors.onSurface2(ctx),
                  side: BorderSide(color: AppThemeColors.fieldBorder(ctx)),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
=======
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink2,
                      side: const BorderSide(color: AppColors.fieldBorder),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                    child: const Text('Not Yet',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                ),
                child: const Text('Not Yet', style: TextStyle(fontWeight: FontWeight.w600)),
              ))),
              const SizedBox(width: 12),
<<<<<<< HEAD
              Expanded(child: SizedBox(height: 52, child: GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await MealService().confirmPickup(_post.id);
                    if (!context.mounted) return;
                    _snack(context, '🎉 Pickup confirmed! Food reached the needy.', AppColors.sage);
                  } catch (e) {
                    if (!context.mounted) return;
                    _snack(context, 'Error: $e', AppColors.terr);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.amber, AppColors.amberDk]),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    boxShadow: [BoxShadow(color: AppColors.amber.withAlpha(71), blurRadius: 10, offset: const Offset(0, 4))],
=======
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await MealService().confirmPickup(_post.id);
                        if (!context.mounted) return;
                        _snack(context,
                            '🎉 Pickup confirmed! Food reached the needy.',
                            AppColors.sage);
                      } catch (e) {
                        if (!context.mounted) return;
                        _snack(context, 'Error: \$e', AppColors.terr);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.amber, AppColors.amberDk]),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: [BoxShadow(
                            color: AppColors.amber.withAlpha(71),
                            blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      alignment: Alignment.center,
                      child: const Text('Yes, Picked Up!',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                  ),
                  alignment: Alignment.center,
                  child: const Text('Yes, Picked Up!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ))),
            ]),
          ]),
        ),
      ),
    );
  }

}

<<<<<<< HEAD
=======

// ─── Empty Tab State ─────────────────────────────────────────────────────────
class _EmptyTabState extends StatelessWidget {
  final String message;
  const _EmptyTabState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.amber.withAlpha(31),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.inbox_outlined, size: 38, color: AppColors.amber),
        ),
        const SizedBox(height: 16),
        Text(message, style: AppTextStyles.sectionHead),
      ]),
    );
  }
}

>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
// ─── Shared AppBar ────────────────────────────────────────────────────────────
class _SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final TabBar? bottom;
  const _SharedAppBar({required this.title, this.actions = const [], this.bottom});

  @override
<<<<<<< HEAD
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom != null ? kTextTabBarHeight : 0));
=======
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom != null ? kTextTabBarHeight : 0));
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return AppBar(
      backgroundColor: AppColors.sageHero,
      foregroundColor: Colors.white,
<<<<<<< HEAD
      elevation: 0, titleSpacing: 0,
      bottom: bottom,
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppGradients.heroBar)),
=======
      elevation: 0,
      titleSpacing: 0,
      bottom: bottom,
      flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.heroBar)),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
      title: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.amberBadge,
              boxShadow: [BoxShadow(color: AppColors.amber.withAlpha(89), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.favorite, size: 20, color: Colors.white.withAlpha(242)),
            const Icon(Icons.handshake, size: 11, color: Color(0xFF92400E)),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.2)),
          const Text('ShareMeal', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400, color: Color(0xCCFFFFFF), letterSpacing: 1.5)),
        ]),
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
    final surfaceHigh = AppThemeColors.surfaceHigh(context);
    final onSurface   = AppThemeColors.onSurface(context);
    final divColor    = AppThemeColors.divider(context);

    return Drawer(
      backgroundColor: surfaceHigh,
      child: Column(children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.heroBar),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.amberBadge,
                  boxShadow: [BoxShadow(color: AppColors.amber.withAlpha(89), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Stack(alignment: Alignment.center, children: [
                Icon(Icons.favorite, size: 30, color: Colors.white.withAlpha(242)),
                const Icon(Icons.handshake, size: 15, color: Color(0xFF92400E)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.orgName ?? 'Guest',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Georgia')),
              const SizedBox(height: 3),
              Text(user?.email ?? '—', style: TextStyle(color: Colors.white.withAlpha(191), fontSize: 12.5)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: AppDecorations.liveBadge,
                child: Text(user?.role ?? 'Donor',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.amberLt, letterSpacing: 0.8)),
              ),
            ])),
          ]),
        ),
        const SizedBox(height: 10),
        _DrawerItem(icon: Icons.location_on_outlined, title: 'My Address',
            subtitle: (user?.address?.trim().isNotEmpty == true) ? user!.address : 'Not set',
            color: AppColors.sage),
        Divider(color: divColor, indent: 20, endIndent: 20),

<<<<<<< HEAD
        // Donation History
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ListTile(
            leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.amber.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.history_rounded, color: AppColors.amber, size: 18)),
            title: Text('Donation History', style: TextStyle(fontWeight: FontWeight.w600, color: onSurface, fontSize: 13.5)),
            trailing: Icon(Icons.chevron_right_rounded, size: 18, color: AppThemeColors.onSurfaceMuted(context)),
=======
        // ── Donation History ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.amber.withAlpha(26),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.amber, size: 18),
            ),
            title: Text('Donation History',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.ink3),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const _DonationHistorySheet(),
              );
            },
          ),
        ),
<<<<<<< HEAD
        Divider(color: divColor, indent: 20, endIndent: 20),

        // Dark Mode toggle
=======
        const Divider(color: AppColors.fieldBorder, indent: 20, endIndent: 20),

>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SwitchListTile(
            secondary: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.sage.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.dark_mode_outlined, color: AppColors.sage, size: 18)),
            title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, color: onSurface, fontSize: 13.5)),
            value: appState.isDarkMode,
            activeThumbColor: AppColors.sage,
            onChanged: (_) => appState.toggleTheme(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const Spacer(),
        Divider(color: divColor, indent: 20, endIndent: 20),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: ListTile(
            leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.terr.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout_rounded, color: AppColors.terr, size: 18)),
            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.terr)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () async {
              await appState.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthWrapper()), (r) => false,
              );
            },
          ),
        ),
      ]),
    );
  }
}

<<<<<<< HEAD
// ─── Donation History Sheet ───────────────────────────────────────────────────
=======
// ─── Donation History Bottom Sheet ────────────────────────────────────────────
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
class _DonationHistorySheet extends StatelessWidget {
  const _DonationHistorySheet();

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return DraggableScrollableSheet(
      initialChildSize: 0.82, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: AppDecorations.draggableSheet(ctx),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppThemeColors.divider(ctx), borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Row(children: [
                Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: AppColors.amber.withAlpha(31), borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.history_rounded, color: AppColors.amber, size: 20)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Donation History', style: AppTextStyles.cardHeadThemed(ctx).copyWith(fontSize: 17)),
                  Text('Completed pickups by NGOs', style: AppTextStyles.bodySmallThemed(ctx)),
                ]),
              ]),
              const SizedBox(height: 12),
              Divider(color: AppThemeColors.divider(ctx)),
=======
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1419) : AppColors.offWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withAlpha(31),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Donation History',
                      style: AppTextStyles.cardHead.copyWith(fontSize: 17)),
                  const Text('Completed pickups by NGOs',
                      style: AppTextStyles.bodySmall),
                ]),
              ]),
              const SizedBox(height: 12),
              const Divider(color: AppColors.fieldBorder),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
            ]),
          ),
          Expanded(
            child: StreamBuilder<List<HistoryEntry>>(
              stream: MealService().streamDonationHistory(),
<<<<<<< HEAD
              builder: (ctx2, snap) {
=======
              builder: (ctx, snap) {
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.sage));
                }
                final entries = snap.data ?? [];
                if (entries.isEmpty) {
<<<<<<< HEAD
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 72, height: 72,
                        decoration: BoxDecoration(color: AppColors.amber.withAlpha(26), shape: BoxShape.circle),
                        child: const Icon(Icons.history_rounded, size: 34, color: AppColors.amber)),
                    const SizedBox(height: 14),
                    Text('No history yet', style: AppTextStyles.sectionHeadThemed(ctx)),
                    const SizedBox(height: 6),
                    Text('Confirmed pickups will appear here', style: AppTextStyles.bodyMutedThemed(ctx)),
                  ]));
=======
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.amber.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_rounded, size: 34, color: AppColors.amber),
                      ),
                      const SizedBox(height: 14),
                      Text('No history yet', style: AppTextStyles.sectionHead),
                      const SizedBox(height: 6),
                      const Text('Confirmed pickups will appear here',
                          style: AppTextStyles.bodyMuted),
                    ]),
                  );
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  itemCount: entries.length,
<<<<<<< HEAD
                  itemBuilder: (_, i) => _HistoryCard(entry: entries[i], partnerLabel: 'Picked up by', accentColor: AppColors.sage),
=======
                  itemBuilder: (_, i) => _HistoryCard(
                    entry: entries[i],
                    partnerLabel: 'Picked up by',
                    accentColor: AppColors.sage,
                  ),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

<<<<<<< HEAD
// ─── Empty States ─────────────────────────────────────────────────────────────
=======
// ─── Shared Empty State ───────────────────────────────────────────────────────
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
class _EmptyState extends StatelessWidget {
  final bool isDonor;
  const _EmptyState({required this.isDonor});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.sage.withAlpha(38), AppColors.sageMid.withAlpha(51)]),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sage.withAlpha(51), width: 1.5),
          ),
          child: Icon(isDonor ? Icons.restaurant_outlined : Icons.search_off_rounded, size: 44, color: AppColors.sage),
        ),
        const SizedBox(height: 20),
        Text(isDonor ? 'No posts yet' : 'No food available', style: AppTextStyles.sectionHeadThemed(context)),
        const SizedBox(height: 8),
        Text(isDonor ? 'Tap + to broadcast your first donation' : 'Check back later for donations',
            style: AppTextStyles.bodyMutedThemed(context)),
      ]),
    );
  }
}

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
      Text(message, style: AppTextStyles.sectionHeadThemed(context)),
    ]),
  );
}

// ─── FAB ─────────────────────────────────────────────────────────────────────
class _GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientFAB({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), gradient: AppGradients.sageButton,
        boxShadow: [BoxShadow(color: AppColors.sage.withAlpha(102), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed, backgroundColor: Colors.transparent, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Post Surplus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  const _GradientButton({required this.label, required this.onPressed, this.isLoading = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: AppGradients.sageButton,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [BoxShadow(color: AppColors.sage.withAlpha(77), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        alignment: Alignment.center,
        child: isLoading
<<<<<<< HEAD
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label, style: AppTextStyles.ctaButton.copyWith(letterSpacing: 0.5, fontSize: 14)),
=======
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label,
                style: AppTextStyles.ctaButton.copyWith(
                    letterSpacing: 0.5, fontSize: 14)),
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
      ),
    );
  }
}

// ─── Sheet Field (theme-aware) ────────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  const _SheetField({required this.controller, required this.hint, required this.icon, this.keyboardType, this.formatters, this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.fieldThemed(context),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        validator: validator,
        style: TextStyle(color: AppThemeColors.onSurface(context), fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(fontSize: 13.5, color: AppThemeColors.onSurfaceMuted(context)),
          prefixIcon: Icon(icon, size: AppDimensions.iconSm, color: AppThemeColors.onSurfaceMuted(context)),
          border: InputBorder.none,
          contentPadding: AppDimensions.fieldContentPad,
          errorStyle: const TextStyle(fontSize: 11, color: AppColors.terr),
        ),
      ),
    );
  }
}

// ─── Badges ───────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: AppDecorations.sagePill,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sage)),
      const SizedBox(width: 5),
      const Text('Active', style: TextStyle(fontSize: 10.5, color: AppColors.sage, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _PickedUpBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.sage.withAlpha(31), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.sage.withAlpha(77))),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inventory_2_outlined, size: 10, color: AppColors.sage),
      SizedBox(width: 5),
      Text('Picked Up', style: TextStyle(fontSize: 10.5, color: AppColors.sage, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _ClaimedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.amber.withAlpha(31), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.amber.withAlpha(77))),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.directions_bike_outlined, size: 10, color: AppColors.amberDk),
      SizedBox(width: 5),
      Text('Claimed', style: TextStyle(fontSize: 10.5, color: AppColors.amberDk, fontWeight: FontWeight.w700)),
    ]),
  );
}

// ─── Veg Toggle ──────────────────────────────────────────────────────────────
class _VegToggle extends StatelessWidget {
  final String label;
  final bool value, group;
  final Color color;
  final ValueChanged<bool?> onChanged;
  const _VegToggle({required this.label, required this.value, required this.group, required this.color, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Radio<bool>(value: value, groupValue: group, onChanged: onChanged, activeColor: color, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    Text(label, style: AppTextStyles.bodyThemed(context).copyWith(color: AppThemeColors.onSurface2(context))),
  ]);
}

// ─── Nutrient Chip ────────────────────────────────────────────────────────────
class _NutrientChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _NutrientChip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final iconSize   = AppResponsive.isLarge ? 6.0  : AppResponsive.r(8).toDouble();
    final iconRadius = AppResponsive.isLarge ? 1.5  : AppResponsive.r(2).toDouble();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(10), vertical: AppResponsive.h(5)),
      decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(AppResponsive.r(20)), border: Border.all(color: color.withAlpha(56))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: iconSize, height: iconSize, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(iconRadius))),
        SizedBox(width: AppResponsive.w(6)),
        Text('$label · $value', style: TextStyle(fontSize: AppResponsive.sp(11.5), fontWeight: FontWeight.w600, color: color.withAlpha(217))),
      ]),
    );
  }
}

// ─── Drawer Item ─────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  const _DrawerItem({required this.icon, required this.title, this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    child: ListTile(
      leading: Container(width: 36, height: 36,
          decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppThemeColors.onSurface(context), fontSize: 13.5)),
      subtitle: (subtitle != null && subtitle!.trim().isNotEmpty)
          ? Text(subtitle!, style: AppTextStyles.bodySmall.copyWith(color: AppThemeColors.onSurfaceMuted(context)), maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

// ─── Food Image ───────────────────────────────────────────────────────────────
class _FoodImage extends StatelessWidget {
  final String img;
  final bool isBase64;
  const _FoodImage({required this.img, required this.isBase64});
  @override
  Widget build(BuildContext context) {
    if (isBase64 && img.isNotEmpty) {
      return Image.memory(base64Decode(img), fit: BoxFit.cover, width: double.infinity,
          errorBuilder: (_, e, s) => _placeholder());
    }
    return Image.network(img, fit: BoxFit.cover, width: double.infinity,
        errorBuilder: (_, e, s) => _placeholder(),
        loadingBuilder: (_, child, progress) => progress == null ? child
            : Container(color: AppColors.sageBg, child: const Center(child: CircularProgressIndicator(color: AppColors.sage, strokeWidth: 2))));
  }
  Widget _placeholder() => Container(color: AppColors.sageBg, child: const Center(child: Icon(Icons.fastfood_outlined, size: 40, color: AppColors.sage)));
}

// ─── History Card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final String partnerLabel;
  final Color accentColor;
  const _HistoryCard({required this.entry, required this.partnerLabel, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final vegColor = entry.isVeg ? AppColors.sage : AppColors.terr;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.cardAccentThemed(context, accentColor),
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
              Expanded(child: Text(entry.item, style: AppTextStyles.bodyThemed(context).copyWith(fontWeight: FontWeight.w700, fontSize: 14.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: accentColor.withAlpha(26), borderRadius: BorderRadius.circular(20), border: Border.all(color: accentColor.withAlpha(56))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle_rounded, size: 10, color: accentColor),
                  const SizedBox(width: 4),
                  Text('Done', style: TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.scale_outlined, size: 12, color: AppColors.ink3),
              const SizedBox(width: 4),
              Text(entry.qty, style: AppTextStyles.bodySmallThemed(context)),
              const SizedBox(width: 10),
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: vegColor)),
              const SizedBox(width: 4),
              Text(entry.isVeg ? 'Veg' : 'Non-Veg', style: TextStyle(fontSize: 11, color: vegColor, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.handshake_outlined, size: 12, color: AppColors.ink3),
              const SizedBox(width: 4),
              Expanded(child: Text('$partnerLabel: ${entry.partnerName}',
                  style: AppTextStyles.bodySmallThemed(context).copyWith(fontSize: 11.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.ink3),
              const SizedBox(width: 4),
              Text(DateFormat('dd MMM yyyy, hh:mm a').format(entry.completedAt),
                  style: AppTextStyles.bodySmallThemed(context).copyWith(fontSize: 10.5)),
            ]),
          ])),
        ]),
      ),
    );
  }
}

void _snack(BuildContext context, String msg, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  ));
<<<<<<< HEAD
=======
}

class _PickedUpBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sage.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sage.withAlpha(77)),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inventory_2_outlined, size: 10, color: AppColors.sage),
        SizedBox(width: 5),
        Text('Picked Up', style: TextStyle(
            fontSize: 10.5, color: AppColors.sage,
            fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _ClaimedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.amber.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withAlpha(77)),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.directions_bike_outlined,
            size: 10, color: AppColors.amberDk),
        SizedBox(width: 5),
        Text('Claimed', style: TextStyle(
            fontSize: 10.5, color: AppColors.amberDk,
            fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─── History Card (shared by Donor & NGO history sheets) ──────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final String partnerLabel;
  final Color accentColor;
  const _HistoryCard({
    required this.entry,
    required this.partnerLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vegColor = entry.isVeg ? AppColors.sage : AppColors.terr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F26) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.ink).withAlpha(30),
            blurRadius: 12, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60, height: 60,
              child: _imgPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(entry.item,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 14.5),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withAlpha(56)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle_rounded, size: 10, color: accentColor),
                    const SizedBox(width: 4),
                    Text('Done', style: TextStyle(
                        fontSize: 10, color: accentColor,
                        fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.scale_outlined, size: 12, color: AppColors.ink3),
                const SizedBox(width: 4),
                Text(entry.qty, style: AppTextStyles.bodySmall),
                const SizedBox(width: 10),
                Container(width: 6, height: 6,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: vegColor)),
                const SizedBox(width: 4),
                Text(entry.isVeg ? 'Veg' : 'Non-Veg',
                    style: TextStyle(fontSize: 11, color: vegColor, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.handshake_outlined, size: 12, color: AppColors.ink3),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('$partnerLabel: ${entry.partnerName}',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11.5),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.access_time_rounded, size: 12, color: AppColors.ink3),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(entry.completedAt),
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10.5),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: AppColors.sageBg,
    child: const Center(child: Icon(Icons.fastfood_outlined, size: 28, color: AppColors.sage)),
  );
>>>>>>> a1d00c08728d397dd8e22e594da0d6b0f5b96422
}