import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/nav_items.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../layout/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_sidebar.dart';

/// The authenticated dashboard shell: sidebar + top bar + active section.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavController>();
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: AppSidebar(
                extended: true,
                onItemSelected: () => Get.back<void>(),
              ),
            )
          : null,
      appBar: isMobile
          ? AppBar(
              title: Obx(() => Text(navItems[nav.index.value].label)),
              actions: const [
                _ThemeToggle(),
                _AccountMenu(),
                SizedBox(width: 8),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) AppSidebar(extended: isDesktop),
          Expanded(
            child: Column(
              children: [
                if (!isMobile) const _TopBar(),
                Expanded(
                  child: Obx(
                    () => IndexedStack(
                      index: nav.index.value,
                      children: navItems.map((e) => e.page).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          const _ThemeToggle(),
          const SizedBox(width: 8),
          const _AccountMenu(),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return Obx(
      () => IconButton(
        tooltip: theme.isDark ? 'Light mode' : 'Dark mode',
        icon: Icon(theme.isDark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined),
        onPressed: theme.toggle,
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == 'logout') auth.signOut();
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Obx(
            () => Text(
              auth.email.value.isEmpty ? 'Admin' : auth.email.value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppColors.danger),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
