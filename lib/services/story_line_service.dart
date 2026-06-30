import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/mock/mock_db.dart';
import '../core/utils/image_formats.dart';
import '../models/story_line.dart';

class StoryLineService {
  Future<List<StoryLine>> fetchAll({String? category, String? query}) async {
    if (SupabaseConfig.isDemoMode) {
      var list = MockDb.instance.storyLines.toList();
      if (category != null && category != 'All') {
        list = list.where((e) => e.category == category).toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list.where((e) => e.title.toLowerCase().contains(q)).toList();
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    var builder = SupabaseConfig.client.from('story_lines').select();
    if (category != null && category != 'All') {
      builder = builder.eq('category', category);
    }
    if (query != null && query.trim().isNotEmpty) {
      builder = builder.ilike('title', '%${query.trim()}%');
    }
    final data = await builder.order('created_at', ascending: false);
    return data.map((e) => StoryLine.fromMap(e)).toList();
  }

  Stream<List<StoryLine>> stream() {
    return SupabaseConfig.client
        .from('story_lines')
        .stream(primaryKey: ['id']).map((rows) {
      // Filter null placeholders supabase_flutter emits after DELETE events.
      final list = rows
          .whereType<Map<String, dynamic>>()
          .map((e) => StoryLine.fromMap(e))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<StoryLine> create({
    required String title,
    required String description,
    required String category,
    required String targetApp,
    required Uint8List bytes,
    required String fileName,
    DateTime? date,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      final story = StoryLine(
        id: MockDb.instance.nextId(),
        title: title,
        description: description,
        category: category,
        targetApp: targetApp,
        imagePath: 'demo/$fileName',
        imageUrl: '',
        isActive: true,
        date: date,
        createdAt: DateTime.now(),
      );
      MockDb.instance.storyLines.insert(0, story);
      return story;
    }

    final client = SupabaseConfig.client;
    final path = 'story_lines/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await client.storage.from(SupabaseConfig.svgBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentTypeForFile(fileName),
            upsert: true,
          ),
        );
    final url =
        client.storage.from(SupabaseConfig.svgBucket).getPublicUrl(path);

    final row = await client
        .from('story_lines')
        .insert({
          'title': title,
          'description': description,
          'category': category,
          'target_app': targetApp,
          'image_path': path,
          'image_url': url,
          'is_active': true,
          if (date != null) 'date': date.toIso8601String().split('T').first,
        })
        .select()
        .single();
    return StoryLine.fromMap(row);
  }

  Future<void> update(
    StoryLine story, {
    Uint8List? bytes,
    String? fileName,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.storyLines;
      final i = list.indexWhere((e) => e.id == story.id);
      if (i != -1) {
        list[i] = (bytes != null && fileName != null)
            ? story.copyWith(imagePath: 'demo/$fileName')
            : story;
      }
      return;
    }

    final client = SupabaseConfig.client;
    final updates = <String, dynamic>{
      'title': story.title,
      'description': story.description,
      'category': story.category,
      'target_app': story.targetApp,
      'is_active': story.isActive,
      if (story.date != null) 'date': story.date!.toIso8601String().split('T').first,
    };

    if (bytes != null && fileName != null) {
      final newPath =
          'story_lines/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await client.storage.from(SupabaseConfig.svgBucket).uploadBinary(
            newPath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentTypeForFile(fileName),
              upsert: true,
            ),
          );
      updates['image_path'] = newPath;
      updates['image_url'] =
          client.storage.from(SupabaseConfig.svgBucket).getPublicUrl(newPath);

      if (story.imagePath.isNotEmpty && story.imagePath != newPath) {
        await client.storage
            .from(SupabaseConfig.svgBucket)
            .remove([story.imagePath]);
      }
    }

    await client.from('story_lines').update(updates).eq('id', story.id);
  }

  Future<void> setActive(StoryLine story, bool value) =>
      update(story.copyWith(isActive: value));

  Future<void> delete(StoryLine story) async {
    if (SupabaseConfig.isDemoMode) {
      MockDb.instance.storyLines.removeWhere((e) => e.id == story.id);
      return;
    }
    final client = SupabaseConfig.client;
    if (story.imagePath.isNotEmpty) {
      await client.storage
          .from(SupabaseConfig.svgBucket)
          .remove([story.imagePath]);
    }
    await client.from('story_lines').delete().eq('id', story.id);
  }
}
