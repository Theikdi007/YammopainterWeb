import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/posts/post_management_screen.dart';
import '../screens/rewards/reward_screen.dart';
import '../screens/story_lines/story_line_management_screen.dart';
import '../screens/svg/svg_management_screen.dart';
import '../screens/users/user_management_screen.dart';

/// A single destination in the dashboard sidebar.
class NavItem {
  const NavItem(this.label, this.icon, this.selectedIcon, this.page);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

const List<NavItem> navItems = [
  NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard,
      DashboardScreen()),
  NavItem('Image Assets', Icons.image_outlined, Icons.image,
      SvgManagementScreen()),
  NavItem('Stories', Icons.auto_stories_outlined, Icons.auto_stories,
      StoryLineManagementScreen()),
  NavItem('Users', Icons.people_outline, Icons.people,
      UserManagementScreen()),
  NavItem('Notifications', Icons.notifications_outlined, Icons.notifications,
      NotificationScreen()),
  NavItem('Rewards', Icons.card_giftcard_outlined, Icons.card_giftcard,
      RewardScreen()),
  NavItem('Community', Icons.dynamic_feed_outlined, Icons.dynamic_feed,
      PostManagementScreen()),
  NavItem('Feedback', Icons.feedback_outlined, Icons.feedback,
      FeedbackScreen()),
];
