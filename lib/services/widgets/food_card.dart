import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharemeal/models/food_post.dart';
import 'package:sharemeal/constants/app_theme.dart';

class FoodCard extends StatelessWidget {
  final FoodPost post;
  final VoidCallback? onClaim;
  final bool isDonorView;

  const FoodCard({
    super.key,
    required this.post,
    this.onClaim,
    this.isDonorView = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor   = ThemeHelper.onSurface(context);
    final mutedColor  = ThemeHelper.onSurfaceMuted(context);
    final accentColor = post.isVeg ? AppColors.sage : AppColors.terr;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ThemeHelper.cardDecoration(context, accentLeft: accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Food image (NGO view only) ────────────────────────────
          if (!isDonorView)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXl)),
              child: Stack(children: [
                post.imgIsBase64 && post.img.isNotEmpty
                    ? Image.memory(
                        base64Decode(post.img),
                        height: AppDimensions.imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(),
                      )
                    : Image.network(
                        post.img,
                        height: AppDimensions.imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                height: AppDimensions.imageHeight,
                                color: AppColors.sageBg,
                                child: const Center(
                                    child: CircularProgressIndicator(color: AppColors.sage, strokeWidth: 2))),
                      ),
                // Veg badge
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (post.isVeg ? AppColors.sage : AppColors.terr).withAlpha(230),
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
                // Distance badge
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.black.withAlpha(133), borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_on_rounded, size: 11, color: AppColors.amberLt),
                      SizedBox(width: 3),
                      Text('2.0 km',
                          style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ),

          // ── Card body ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Title + qty badge
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(post.item,
                      style: TextStyle(
                          fontFamily: 'Georgia', fontSize: 16,
                          fontWeight: FontWeight.w700, color: textColor)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withAlpha(31),
                    border: Border.all(color: AppColors.amber.withAlpha(77)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(post.qty,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.amberDk)),
                ),
              ]),
              const SizedBox(height: 8),

              // Meta row — time + veg indicator / distance
              Row(children: [
                Icon(Icons.access_time_rounded, size: 13, color: mutedColor),
                const SizedBox(width: 4),
                Text(DateFormat('hh:mm a').format(post.time),
                    style: TextStyle(fontSize: 12.5, color: mutedColor)),
                const SizedBox(width: 12),
                if (isDonorView) ...[
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor)),
                  const SizedBox(width: 4),
                  Text(post.isVeg ? 'Veg' : 'Non-Veg',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: accentColor)),
                ] else ...[
                  Icon(Icons.location_on_outlined, size: 13, color: mutedColor),
                  const SizedBox(width: 3),
                  Text('2.0 km',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: mutedColor)),
                ],
              ]),

              // Claim button (NGO view)
              if (onClaim != null) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onClaim,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: AppGradients.sageButton,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      boxShadow: [
                        BoxShadow(color: AppColors.sage.withAlpha(71), blurRadius: 14, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 17),
                      SizedBox(width: 8),
                      Text('CLAIM NOW',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700,
                              fontSize: 13, letterSpacing: 1.2)),
                    ]),
                  ),
                ),
              ],

              // Active badge (donor view)
              if (isDonorView) ...[
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      // Use theme-aware sage bg so it works in dark mode
                      color: ThemeHelper.sageBg(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.sage.withAlpha(51)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 5, height: 5,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sage)),
                      const SizedBox(width: 5),
                      const Text('Active',
                          style: TextStyle(fontSize: 10.5, color: AppColors.sage, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    height: AppDimensions.imageHeight,
    color: AppColors.sageBg,
    child: const Center(child: Icon(Icons.fastfood_outlined, size: 48, color: AppColors.sage)),
  );
}