import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sharemeal/models/app_state.dart';
import 'package:sharemeal/models/food_post.dart';
import 'package:sharemeal/constants/app_theme.dart';
import 'package:sharemeal/screens/login_screen.dart';
import 'package:sharemeal/services/meal_service.dart';

class NGODashboard extends StatefulWidget {
  const NGODashboard({super.key});
  @override
  State<NGODashboard> createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user     = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _SharedAppBar(
        title: 'NGO Live Feed',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppDecorations.liveBadge,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 5, height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.amberLt,
                  boxShadow: [BoxShadow(color: AppColors.amber, blurRadius: 5)],
                ),
              ),
              const SizedBox(width: 5),
              Text('LIVE', style: AppTextStyles.liveLabel),
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
      body: StreamBuilder<List<FoodPost>>(
  stream: MealService().streamAvailableMeals(),
  builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
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
            ),
          );
  },
),
    );
  }
}

// ─── Food Card ────────────────────────────────────────────────────────────────
class _FoodCard extends StatelessWidget {
  final FoodPost post;
  final int index;
  const _FoodCard({required this.post, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withOpacity(0.06),
              blurRadius: 18, offset: const Offset(0, 4)),
          BoxShadow(color: AppColors.ink.withOpacity(0.03),
              blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Food image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Stack(children: [
            Image.network(
              post.img, height: 170, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 170, color: AppColors.sageBg,
                child: const Center(child: Icon(Icons.fastfood_outlined,
                    size: 52, color: AppColors.sage)),
              ),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(height: 170, color: AppColors.sageBg,
                      child: const Center(child: CircularProgressIndicator(
                          color: AppColors.sage, strokeWidth: 2))),
            ),
            // Veg badge
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (post.isVeg ? AppColors.sage : AppColors.terr)
                      .withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white)),
                  const SizedBox(width: 5),
                  Text(post.isVeg ? 'Veg' : 'Non-Veg',
                      style: const TextStyle(fontSize: 10.5,
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            // Distance badge
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_rounded,
                      size: 11, color: AppColors.amberLt),
                  const SizedBox(width: 3),
                  const Text('2.0 km', style: TextStyle(fontSize: 10.5,
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(post.item,
                  style: AppTextStyles.sectionHead.copyWith(fontSize: 18))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.12),
                  border: Border.all(color: AppColors.amber.withOpacity(0.30)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(post.qty, style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700, color: AppColors.amberDk)),
              ),
            ]),
            const SizedBox(height: 8),

            Row(children: [
              const Icon(Icons.business_outlined, size: 13, color: AppColors.ink3),
              const SizedBox(width: 4),
              Expanded(child: Text(post.donor, style: AppTextStyles.bodySmall)),
              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.ink3),
              const SizedBox(width: 4),
              Text(DateFormat('hh:mm a').format(post.time),
                  style: AppTextStyles.bodySmall),
            ]),

            if (post.nutrients != null) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _NutrientChip('🔥 Cal',  post.nutrients!.caloriesStr, Colors.deepOrange),
                _NutrientChip('Protein', post.nutrients!.proteinStr,  const Color(0xFF5B8DEF)),
                _NutrientChip('Carbs',   post.nutrients!.carbsStr,    AppColors.amber),
                _NutrientChip('Fat',     post.nutrients!.fatStr,      AppColors.terr),
              ]),
            ],

            const SizedBox(height: 14),

            // Claim button
            GestureDetector(
              onTap: () => _showDetails(context, post, index),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.sageButton,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [BoxShadow(color: AppColors.sage.withOpacity(0.28),
                      blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('CLAIM FOOD', style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showDetails(BuildContext context, FoodPost post, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                    gradient: AppGradients.sageButton,
                    borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.fastfood_outlined,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.item, style: AppTextStyles.sectionHead),
                Text('From: ${post.donor}', style: AppTextStyles.bodySmall),
              ])),
            ]),

            if (post.nutrients != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sageBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sage.withOpacity(0.20)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.local_dining_outlined,
                        color: AppColors.sage, size: 16),
                    const SizedBox(width: 6),
                    Text('Nutrition Facts',
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.sage)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: post.nutrients!.source == 'api'
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post.nutrients!.source == 'api' ? 'Live API' : 'Estimated',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: post.nutrients!.source == 'api'
                              ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _NutrientBox('🔥 Cal',    post.nutrients!.caloriesStr, Colors.deepOrange)),
                    const SizedBox(width: 8),
                    Expanded(child: _NutrientBox('Protein', post.nutrients!.proteinStr,  const Color(0xFF5B8DEF))),
                    const SizedBox(width: 8),
                    Expanded(child: _NutrientBox('Carbs',   post.nutrients!.carbsStr,    AppColors.amber)),
                    const SizedBox(width: 8),
                    Expanded(child: _NutrientBox('Fat',     post.nutrients!.fatStr,      AppColors.terr)),
                  ]),
                  const SizedBox(height: 10),
                  _InfoRow('Fiber',       post.nutrients!.fiberStr),
                  _InfoRow('Sugar',       post.nutrients!.sugarStr),
                  _InfoRow('Sodium',      post.nutrients!.sodiumStr),
                  _InfoRow('Cholesterol', post.nutrients!.cholesterolStr),
                  if (post.nutrients!.servingSize > 0)
                    _InfoRow('Serving',   post.nutrients!.servingSizeStr),
                ]),
              ),
            ],

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amber.withOpacity(0.22)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.amberDk),
                const SizedBox(width: 8),
                const Expanded(child: Text(
                    'Donor will be notified when you confirm pickup',
                    style: TextStyle(fontSize: 11.5,
                        color: AppColors.amberDk))),
              ]),
            ),

            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink2,
                    side: BorderSide(color: AppColors.fieldBorder),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd)),
                  ),
                  child: const Text('Close',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmClaim(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: AppGradients.sageButton,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd),
                      boxShadow: [BoxShadow(
                          color: AppColors.sage.withOpacity(0.28),
                          blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Claim Food',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _confirmClaim(BuildContext context) {
    final p = post;
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: AppGradients.sageButton,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.sage.withOpacity(0.30),
                    blurRadius: 16, offset: const Offset(0, 5))],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),

            Text('Confirm Claim', style: AppTextStyles.sectionHead),
            const SizedBox(height: 6),
            Text('You are claiming:', style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sageBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sage.withOpacity(0.20)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(p.item, style: AppTextStyles.body.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Qty: ${p.qty}  •  From: ${p.donor}',
                    style: AppTextStyles.bodySmall),
              ]),
            ),
            const SizedBox(height: 20),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink2,
                    side: BorderSide(color: AppColors.fieldBorder),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await MealService().claimMeal(post.id);
                      Navigator.pop(ctx);
                      _snack(context, '✅ Food claimed! Donor has been notified', AppColors.sage);
                    } catch (e) {
                      _snack(context, 'Error: $e', AppColors.terr);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: AppGradients.sageButton,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd),
                      boxShadow: [BoxShadow(
                          color: AppColors.sage.withOpacity(0.28),
                          blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Confirm Pickup',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
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
  const _SharedAppBar({required this.title, this.actions = const []});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.sageHero,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.heroBar)),
      title: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.amberBadge,
            boxShadow: [BoxShadow(color: AppColors.amber.withOpacity(0.35),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.favorite, size: 20, color: Colors.white.withOpacity(0.95)),
            const Icon(Icons.handshake, size: 11, color: Color(0xFF92400E)),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontFamily: 'Georgia',
              fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.2)),
          const Text('ShareMeal', style: TextStyle(fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: Color(0xCCFFFFFF), letterSpacing: 1.5)),
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
    return Drawer(
      backgroundColor: AppColors.offWhite,
      child: Column(children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.heroBar),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.amberBadge,
                boxShadow: [BoxShadow(color: AppColors.amber.withOpacity(0.35),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Stack(alignment: Alignment.center, children: [
                Icon(Icons.favorite, size: 30,
                    color: Colors.white.withOpacity(0.95)),
                const Icon(Icons.handshake, size: 15,
                    color: Color(0xFF92400E)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.orgName ?? 'Guest',
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 16,
                      fontFamily: 'Georgia')),
              const SizedBox(height: 3),
              Text(user?.email ?? '—',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 12.5)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: AppDecorations.liveBadge,
                child: Text(user?.role ?? 'User',
                    style: const TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amberLt, letterSpacing: 0.8)),
              ),
            ])),
          ]),
        ),

        const SizedBox(height: 10),
        _DrawerItem(icon: Icons.location_on_outlined, title: 'My Address',
            subtitle: user?.address ?? 'Not set', color: AppColors.sage),
        Divider(color: AppColors.fieldBorder, indent: 20, endIndent: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SwitchListTile(
            secondary: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.sage.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.dark_mode_outlined,
                  color: AppColors.sage, size: 18),
            ),
            title: Text('Dark Mode',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            value: appState.isDarkMode,
            activeColor: AppColors.sage,
            onChanged: (_) => appState.toggleTheme(),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const Spacer(),
        Divider(color: AppColors.fieldBorder, indent: 20, endIndent: 20),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.terr.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.terr, size: 18),
            ),
            title: Text('Logout',
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.terr)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            onTap: () async {
              await appState.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─── Shared Empty State ───────────────────────────────────────────────────────
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
            gradient: LinearGradient(colors: [
              AppColors.sage.withOpacity(0.12),
              AppColors.sageMid.withOpacity(0.18),
            ]),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.sage.withOpacity(0.20), width: 1.5),
          ),
          child: Icon(
              isDonor ? Icons.restaurant_outlined : Icons.search_off_rounded,
              size: 44, color: AppColors.sage),
        ),
        const SizedBox(height: 20),
        Text(isDonor ? 'No posts yet' : 'No food available',
            style: AppTextStyles.sectionHead),
        const SizedBox(height: 8),
        Text(
          isDonor
              ? 'Tap + to broadcast your first donation'
              : 'Check back later for donations',
          style: AppTextStyles.bodyMuted,
        ),
      ]),
    );
  }
}

// ─── Nutrient Box ─────────────────────────────────────────────────────────────
class _NutrientBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _NutrientBox(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 3),
        Text(label, style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(value, style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.ink2)),
        ],
      ),
    );
  }
}

// ─── Nutrient Chip ────────────────────────────────────────────────────────────
class _NutrientChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _NutrientChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label · $value',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.85),
          ),
        ),
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
  const _DrawerItem({required this.icon, required this.title,
      this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTextStyles.bodySmall) : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

void _snack(BuildContext context, String msg, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  ));
}