import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_post.dart';
import '../constants/app_theme.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        // left accent bar — sage for veg, terracotta for non-veg
        border: Border(
          left: BorderSide(
            color: post.isVeg ? AppColors.sage : AppColors.terr,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.ink.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Food image (NGO view only) ──────────────────────────────────
          if (!isDonorView)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXl)),
              child: Stack(
                children: [
                  Image.network(
                    post.img,
                    height: AppDimensions.imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: AppDimensions.imageHeight,
                      color: AppColors.sageBg,
                      child: const Center(
                        child: Icon(Icons.fastfood_outlined,
                            size: 48, color: AppColors.sage),
                      ),
                    ),
                    loadingBuilder: (_, child, progress) =>
                        progress == null
                            ? child
                            : Container(
                                height: AppDimensions.imageHeight,
                                color: AppColors.sageBg,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.sage, strokeWidth: 2),
                                ),
                              ),
                  ),
                  // Veg badge
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (post.isVeg ? AppColors.sage : AppColors.terr)
                            .withOpacity(0.90),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          post.isVeg ? 'Veg' : 'Non-Veg',
                          style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ]),
                    ),
                  ),
                  // Distance badge
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.52),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: AppColors.amberLt),
                        const SizedBox(width: 3),
                        const Text('2.0 km',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

          // ── Card body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + qty badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        post.item,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.12),
                        border: Border.all(
                            color: AppColors.amber.withOpacity(0.30)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post.qty,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amberDk),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Meta row — time + veg indicator (donor view) or distance (NGO view)
                Row(children: [
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: AppColors.ink3),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('hh:mm a').format(post.time),
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.ink3),
                  ),
                  const SizedBox(width: 12),
                  if (isDonorView) ...[
                    // Veg dot indicator
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: post.isVeg ? AppColors.sage : AppColors.terr,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.isVeg ? 'Veg' : 'Non-Veg',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: post.isVeg ? AppColors.sage : AppColors.terr,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.terr),
                    const SizedBox(width: 3),
                    const Text('2.0 km',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.terr)),
                  ],
                ]),

                // ── Claim button (NGO view) ──────────────────────────────
                if (onClaim != null) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: onClaim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sageButton,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sage.withOpacity(0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: Colors.white, size: 17),
                          SizedBox(width: 8),
                          Text(
                            'CLAIM NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Edit hint (donor view) ───────────────────────────────
                if (isDonorView) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.sageBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.sage.withOpacity(0.20)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.sage),
                          ),
                          const SizedBox(width: 5),
                          const Text('Active',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.sage,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}