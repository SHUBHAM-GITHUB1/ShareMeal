import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/food_post.dart';
import '../models/app_state.dart';
import '../models/nutrient_data.dart';
import '../constants/app_theme.dart';
import 'login_screen.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});
  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final _formKey  = GlobalKey<FormState>();
  final _itemCtrl = TextEditingController();
  final _qtyCtrl  = TextEditingController();
  bool _isVeg     = true;

  @override
  void dispose() {
    _itemCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  String _fmt(String t) =>
      t.isEmpty ? t : t[0].toUpperCase() + t.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user     = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _SharedAppBar(title: 'Donor Portal', actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 22),
          onPressed: () {
            setState(() {});
            _snack(context, '✓ Refreshed', AppColors.sage);
          },
        ),
      ]),
      drawer: _SharedDrawer(user: user, appState: appState),
      body: appState.allPosts.isEmpty
          ? const _EmptyState(isDonor: true)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
              itemCount: appState.allPosts.length,
              itemBuilder: (_, i) =>
                  _DonorPostCard(post: appState.allPosts[i], index: i),
            ),
      floatingActionButton: _GradientFAB(
        onPressed: () => _showForm(context, user?.orgName ?? 'Anonymous'),
      ),
    );
  }

  void _showForm(BuildContext context, String donorName) {
    setState(() => _isVeg = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24, right: 24, top: 8,
          ),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: AppGradients.sageButton,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [BoxShadow(color: AppColors.sage.withOpacity(0.25),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.broadcast_on_personal_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Broadcast Donation',
                      style: AppTextStyles.cardHead.copyWith(
                          fontSize: 17, fontStyle: FontStyle.normal)),
                  Text('Notify nearby NGOs instantly', style: AppTextStyles.bodySmall),
                ]),
              ]),
              const SizedBox(height: 24),

              Text('FOOD ITEM', style: AppTextStyles.fieldLabel),
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
              const SizedBox(height: 14),

              Text('QUANTITY (KG)', style: AppTextStyles.fieldLabel),
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

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Row(children: [
                  Text('Food Type',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  _VegToggle(label: '🟢  Veg',     value: true,  group: _isVeg, color: AppColors.sage, onChanged: (v) => setModal(() => _isVeg = v!)),
                  const SizedBox(width: 12),
                  _VegToggle(label: '🔴  Non-Veg', value: false, group: _isVeg, color: AppColors.terr, onChanged: (v) => setModal(() => _isVeg = v!)),
                ]),
              ),
              const SizedBox(height: 24),

              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink2,
                      side: BorderSide(color: AppColors.fieldBorder),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _GradientButton(
                    label: 'Post Donation',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final nutrients = NutrientData.getNutrients(_itemCtrl.text.trim());
                        Provider.of<AppState>(context, listen: false).addPost(FoodPost(
                          id:        DateTime.now().millisecondsSinceEpoch.toString(),
                          item:      _fmt(_itemCtrl.text.trim()),
                          qty:       '${_qtyCtrl.text.trim()} Kg',
                          img:       'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
                          time:      DateTime.now(),
                          donor:     donorName,
                          isVeg:     _isVeg,
                          nutrients: nutrients,
                        ));
                        Navigator.pop(context);
                        _itemCtrl.clear();
                        _qtyCtrl.clear();
                        _snack(context, '✅ Food posted successfully!', AppColors.sage);
                      }
                    },
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Donor Post Card ──────────────────────────────────────────────────────────
class _DonorPostCard extends StatelessWidget {
  final FoodPost post;
  final int index;
  const _DonorPostCard({required this.post, required this.index});

  @override
  Widget build(BuildContext context) {
    final accent = post.isVeg ? AppColors.sage : AppColors.terr;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border(left: BorderSide(color: accent, width: 3)),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withOpacity(0.05),
              blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: AppColors.ink.withOpacity(0.03),
              blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.fastfood_outlined, color: accent, size: 24),
          ),
          const SizedBox(width: 14),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(post.item,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 15.5))),
                _StatusBadge(),
              ]),
              const SizedBox(height: 6),

              Row(children: [
                Icon(Icons.scale_outlined, size: 13, color: AppColors.ink3),
                const SizedBox(width: 4),
                Text(post.qty,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink2)),
                const SizedBox(width: 12),
                Icon(Icons.access_time_rounded, size: 13, color: AppColors.ink3),
                const SizedBox(width: 4),
                Text(DateFormat('hh:mm a').format(post.time),
                    style: AppTextStyles.bodySmall),
                const SizedBox(width: 12),
                Container(width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
                const SizedBox(width: 4),
                Text(post.isVeg ? 'Veg' : 'Non-Veg',
                    style: TextStyle(fontSize: 11.5,
                        fontWeight: FontWeight.w600, color: accent)),
              ]),

              if (post.nutrients != null) ...[
                const SizedBox(height: 10),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  _NutrientChip('Protein',  post.nutrients!.protein,  const Color(0xFF5B8DEF)),
                  _NutrientChip('Carbs',    post.nutrients!.carbs,    AppColors.amber),
                  _NutrientChip('Fat',      post.nutrients!.fat,      AppColors.terr),
                  _NutrientChip('Vitamins', post.nutrients!.vitamins, const Color(0xFF8B5CF6)),
                ]),
              ],
            ],
          )),
        ]),
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
                Icon(Icons.favorite, size: 30, color: Colors.white.withOpacity(0.95)),
                const Icon(Icons.handshake, size: 15, color: Color(0xFF92400E)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: Text(user?.role ?? 'Donor',
                      style: const TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.amberLt, letterSpacing: 0.8)),
                ),
              ],
            )),
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
            onTap: () {
              appState.logout();
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
              AppColors.sage.withOpacity(0.15),
              AppColors.sageMid.withOpacity(0.20),
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

// ─── FAB ─────────────────────────────────────────────────────────────────────
class _GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientFAB({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppGradients.sageButton,
        boxShadow: [BoxShadow(color: AppColors.sage.withOpacity(0.40),
            blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Post Surplus',
            style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: AppGradients.sageButton,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [BoxShadow(color: AppColors.sage.withOpacity(0.30),
              blurRadius: 14, offset: const Offset(0, 5))],
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppTextStyles.ctaButton.copyWith(
                letterSpacing: 0.5, fontSize: 14)),
      ),
    );
  }
}

// ─── Sheet Field ──────────────────────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  const _SheetField({
    required this.controller, required this.hint, required this.icon,
    this.keyboardType, this.formatters, this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.field,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        validator: validator,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(fontSize: 13.5),
          prefixIcon: Icon(icon,
              size: AppDimensions.iconSm, color: AppColors.ink3),
          border: InputBorder.none,
          contentPadding: AppDimensions.fieldContentPad,
          errorStyle: TextStyle(fontSize: 11, color: AppColors.terr),
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: AppDecorations.sagePill,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.sage)),
        const SizedBox(width: 5),
        const Text('Active', style: TextStyle(
            fontSize: 10.5, color: AppColors.sage,
            fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─── Veg Toggle ──────────────────────────────────────────────────────────────
class _VegToggle extends StatelessWidget {
  final String label;
  final bool value, group;
  final Color color;
  final ValueChanged<bool?> onChanged;
  const _VegToggle({required this.label, required this.value,
      required this.group, required this.color, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<bool>(value: value, groupValue: group, onChanged: onChanged,
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      Text(label, style: AppTextStyles.body.copyWith(color: AppColors.ink2)),
    ]);
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