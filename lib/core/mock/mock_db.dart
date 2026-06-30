import '../../models/app_notification.dart';
import '../../models/community_post.dart';
import '../../models/feedback_entry.dart';
import '../../models/portal_user.dart';
import '../../models/reward.dart';
import '../../models/story_line.dart';
import '../../models/svg_asset.dart';

/// In-memory data store used when Supabase credentials are not configured.
///
/// Every service falls back to this store in demo mode so the portal is fully
/// browsable and mutations behave realistically within the session.
class MockDb {
  MockDb._();
  static final MockDb instance = MockDb._();

  int _seq = 1000;
  String nextId() => 'mock-${_seq++}';

  DateTime _daysAgo(int d) => DateTime.now().subtract(Duration(days: d));

  late final List<StoryLine> storyLines = [
    StoryLine(
      id: 'str-1',
      title: 'Learn to Draw a Dinosaur',
      description: 'Step-by-step guide to drawing a friendly dinosaur.',
      category: 'Drawing',
      targetApp: 'AR Drawing',
      imagePath: 'demo/story_dino.svg',
      imageUrl: '',
      isActive: true,
      date: _daysAgo(1),
      createdAt: _daysAgo(1),
    ),
    StoryLine(
      id: 'str-2',
      title: 'Sunset Painting Challenge',
      description: 'Create a beautiful sunset painting with simple steps.',
      category: 'Painting',
      targetApp: 'Painting',
      imagePath: 'demo/story_sunset.svg',
      imageUrl: '',
      isActive: true,
      date: _daysAgo(3),
      createdAt: _daysAgo(3),
    ),
    StoryLine(
      id: 'str-3',
      title: 'Ocean Puzzle Adventure',
      description: 'Solve ocean-themed puzzles and earn rewards.',
      category: 'Puzzle',
      targetApp: 'Puzzle',
      imagePath: 'demo/story_ocean.svg',
      imageUrl: '',
      isActive: false,
      date: _daysAgo(7),
      createdAt: _daysAgo(7),
    ),
  ];

  late final List<SvgAsset> svgAssets = [
    SvgAsset(
      id: 'svg-1',
      name: 'Cartoon Cat',
      description: 'A friendly cat outline for kids.',
      category: 'Drawing',
      targetApp: 'AR Drawing',
      filePath: 'demo/cat.svg',
      publicUrl: '',
      isActive: true,
      createdAt: _daysAgo(2),
    ),
    SvgAsset(
      id: 'svg-2',
      name: 'Sunflower',
      description: 'Bright sunflower for painting practice.',
      category: 'Painting',
      targetApp: 'Painting',
      filePath: 'demo/sunflower.svg',
      publicUrl: '',
      isActive: true,
      createdAt: _daysAgo(5),
    ),
    SvgAsset(
      id: 'svg-3',
      name: 'Jigsaw Bear',
      description: 'Bear shaped puzzle pieces.',
      category: 'Puzzle',
      targetApp: 'Puzzle',
      filePath: 'demo/bear.svg',
      publicUrl: '',
      isActive: false,
      createdAt: _daysAgo(9),
    ),
  ];

  late final List<PortalUser> users = [
    PortalUser(
      id: 'usr-1',
      email: 'admin@yammo.app',
      fullName: 'Super Admin',
      role: 'admin',
      isActive: true,
      createdAt: _daysAgo(40),
    ),
    PortalUser(
      id: 'usr-2',
      email: 'editor@yammo.app',
      fullName: 'Content Editor',
      role: 'editor',
      isActive: true,
      createdAt: _daysAgo(20),
    ),
    PortalUser(
      id: 'usr-3',
      email: 'reviewer@yammo.app',
      fullName: 'Jane Reviewer',
      role: 'editor',
      isActive: false,
      createdAt: _daysAgo(8),
    ),
  ];

  late final List<AppNotification> notifications = [
    AppNotification(
      id: 'ntf-1',
      title: 'New images added!',
      body: 'Check out 12 new drawings in the AR Drawing app.',
      target: 'all',
      targetValue: '',
      status: 'sent',
      sentAt: _daysAgo(1),
    ),
    AppNotification(
      id: 'ntf-2',
      title: 'Weekend painting challenge',
      body: 'Join the weekend challenge and earn 100 coins.',
      target: 'group',
      targetValue: 'painters',
      status: 'sent',
      sentAt: _daysAgo(4),
    ),
  ];

  late final List<Reward> rewards = [
    Reward(
      id: 'rwd-1',
      name: 'Welcome Bonus',
      description: '50 coins for new users.',
      points: 50,
      type: 'coins',
      isActive: true,
      createdAt: _daysAgo(30),
    ),
    Reward(
      id: 'rwd-2',
      name: 'Master Painter Badge',
      description: 'Awarded after completing 20 paintings.',
      points: 0,
      type: 'badge',
      isActive: true,
      createdAt: _daysAgo(18),
    ),
    Reward(
      id: 'rwd-3',
      name: 'Premium Puzzle Pack',
      description: 'Unlocks an exclusive puzzle pack.',
      points: 200,
      type: 'unlock',
      isActive: false,
      createdAt: _daysAgo(6),
    ),
  ];

  late final List<UserReward> userRewards = [
    UserReward(
      id: 'urw-1',
      userEmail: 'kid1@example.com',
      rewardName: 'Welcome Bonus',
      points: 50,
      status: 'granted',
      awardedAt: _daysAgo(3),
    ),
    UserReward(
      id: 'urw-2',
      userEmail: 'artist@example.com',
      rewardName: 'Master Painter Badge',
      points: 0,
      status: 'granted',
      awardedAt: _daysAgo(2),
    ),
    UserReward(
      id: 'urw-3',
      userEmail: 'kid1@example.com',
      rewardName: 'Premium Puzzle Pack',
      points: 200,
      status: 'redeemed',
      awardedAt: _daysAgo(1),
    ),
  ];

  late final List<CommunityPost> posts = [
    CommunityPost(
      id: 'pst-1',
      userName: 'Little Picasso',
      userEmail: 'kid1@example.com',
      imageUrl: 'https://picsum.photos/seed/art1/600/400',
      description: 'My first AR drawing of a dinosaur! 🦕',
      likes: 124,
      comments: 18,
      status: 'active',
      createdAt: _daysAgo(1),
    ),
    CommunityPost(
      id: 'pst-2',
      userName: 'ColorQueen',
      userEmail: 'artist@example.com',
      imageUrl: 'https://picsum.photos/seed/art2/600/400',
      description: 'Sunset painting finished today.',
      likes: 89,
      comments: 7,
      status: 'reported',
      createdAt: _daysAgo(2),
    ),
    CommunityPost(
      id: 'pst-3',
      userName: 'PuzzleMaster',
      userEmail: 'gamer@example.com',
      imageUrl: 'https://picsum.photos/seed/art3/600/400',
      description: 'Completed the 500 piece bear puzzle!',
      likes: 56,
      comments: 4,
      status: 'active',
      createdAt: _daysAgo(3),
    ),
  ];

  late final List<FeedbackEntry> feedback = [
    FeedbackEntry(
      id: 'fbk-1',
      userId: 'user-1042',
      category: 'praise',
      sentiment: 'happy',
      message: 'My kid loves the new puzzle pack! Thank you 🎉',
      platform: 'ios',
      appVersion: '1.4.0',
      createdAt: _daysAgo(1),
    ),
    FeedbackEntry(
      id: 'fbk-2',
      userId: 'user-2087',
      category: 'bug',
      sentiment: 'sad',
      message: 'The drawing canvas freezes when I pick the red brush.',
      platform: 'android',
      appVersion: '1.3.9',
      createdAt: _daysAgo(2),
    ),
    FeedbackEntry(
      id: 'fbk-3',
      userId: 'user-3310',
      category: 'suggestion',
      sentiment: 'neutral',
      message: 'Please add more dinosaur outlines for the AR drawing mode.',
      platform: 'ios',
      appVersion: '1.4.0',
      createdAt: _daysAgo(4),
    ),
  ];
}
