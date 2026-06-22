import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/nav_items.dart';
import '../controllers/nav_controller.dart';
import '../core/config/supabase_config.dart';
import '../theme/app_colors.dart';

/// Left navigation rail for the dashboard. Stays dark in both themes.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, this.extended = true, this.onItemSelected});

  final bool extended;
  final VoidCallback? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavController>();
    return Container(
      width: extended ? 256 : 80,
      color: AppColors.darkSidebar,
      child: SafeArea(
        child: Column(
          children: [
            _header(context),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: navItems.length,
                itemBuilder: (context, i) => _tile(nav, i),
              ),
            ),
            if (SupabaseConfig.isDemoMode) _demoBadge(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment:
            extended ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.palette_outlined,
                color: Colors.white, size: 22),
          ),
          if (extended) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Yammo Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(NavController nav, int i) {
    final item = navItems[i];
    return Obx(() {
      final selected = nav.index.value == i;
      final color = selected ? Colors.white : AppColors.textMutedOnDark;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Material(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              nav.select(i);
              onItemSelected?.call();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(selected ? item.selectedIcon : item.icon,
                      color: color, size: 22),
                  if (extended) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _demoBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined,
              color: AppColors.warning, size: 18),
          if (extended) ...[
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Demo mode',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
