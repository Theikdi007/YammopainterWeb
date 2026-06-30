import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/mock/mock_db.dart';
import '../core/utils/image_formats.dart';
import '../models/svg_asset.dart';

/// CRUD + storage operations for SVG assets.
class SvgService {
  Future<List<SvgAsset>> fetchAll({String? category, String? query}) async {
    if (SupabaseConfig.isDemoMode) {
      var list = MockDb.instance.svgAssets.toList();
      if (category != null && category != 'All') {
        list = list.where((e) => e.category == category).toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list.where((e) => e.name.toLowerCase().contains(q)).toList();
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    var builder = SupabaseConfig.client.from('svg_assets').select();
    if (category != null && category != 'All') {
      builder = builder.eq('category', category);
    }
    if (query != null && query.trim().isNotEmpty) {
      builder = builder.ilike('name', '%${query.trim()}%');
    }
    final data = await builder.order('created_at', ascending: false);
    return data.map((e) => SvgAsset.fromMap(e)).toList();
  }

  /// Realtime stream of all assets (newest first). Filtering is applied
  /// client-side by the controller. Only valid when Supabase is configured.
  ///
  /// supabase_flutter can emit a `null` entry in the row list after a DELETE
  /// event (its internal cache stores a null placeholder). Filter those out
  /// before parsing so the stream never throws a Null-to-Map cast error and
  /// the controller stays clean.
  Stream<List<SvgAsset>> stream() {
    return SupabaseConfig.client
        .from('svg_assets')
        .stream(primaryKey: ['id']).map((rows) {
      final list = rows
          .whereType<Map<String, dynamic>>()
          .map((e) => SvgAsset.fromMap(e))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<SvgAsset> create({
    required String name,
    required String description,
    required String category,
    required String targetApp,
    required Uint8List bytes,
    required String fileName,
    String? storyLineId,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      final asset = SvgAsset(
        id: MockDb.instance.nextId(),
        name: name,
        description: description,
        category: category,
        targetApp: targetApp,
        filePath: 'demo/$fileName',
        publicUrl: '',
        isActive: true,
        storyLineId: storyLineId,
        createdAt: DateTime.now(),
      );
      MockDb.instance.svgAssets.insert(0, asset);
      return asset;
    }

    final client = SupabaseConfig.client;
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
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
        .from('svg_assets')
        .insert({
          'name': name,
          'description': description,
          'category': category,
          'target_app': targetApp,
          'file_path': path,
          'public_url': url,
          'is_active': true,
          if (storyLineId != null) 'story_line_id': storyLineId,
        })
        .select()
        .single();
    return SvgAsset.fromMap(row);
  }

  /// Updates an asset's metadata. When [bytes] and [fileName] are supplied the
  /// stored file is replaced too: the new file is uploaded under a fresh path
  /// (so its public URL changes and avoids stale caches) and the old object is
  /// removed once the replacement is in place.
  Future<void> update(
    SvgAsset asset, {
    Uint8List? bytes,
    String? fileName,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.svgAssets;
      final i = list.indexWhere((e) => e.id == asset.id);
      if (i != -1) {
        // No real storage in demo mode; just reflect the new file name.
        list[i] = (bytes != null && fileName != null)
            ? asset.copyWith(filePath: 'demo/$fileName')
            : asset;
      }
      return;
    }

    final client = SupabaseConfig.client;
    final updates = <String, dynamic>{
      'name': asset.name,
      'description': asset.description,
      'category': asset.category,
      'target_app': asset.targetApp,
      'is_active': asset.isActive,
      'story_line_id': asset.storyLineId,
    };

    if (bytes != null && fileName != null) {
      final newPath = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await client.storage.from(SupabaseConfig.svgBucket).uploadBinary(
            newPath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentTypeForFile(fileName),
              upsert: true,
            ),
          );
      updates['file_path'] = newPath;
      updates['public_url'] =
          client.storage.from(SupabaseConfig.svgBucket).getPublicUrl(newPath);

      // Remove the previous object now that the replacement is uploaded.
      if (asset.filePath.isNotEmpty && asset.filePath != newPath) {
        await client.storage
            .from(SupabaseConfig.svgBucket)
            .remove([asset.filePath]);
      }
    }

    await client.from('svg_assets').update(updates).eq('id', asset.id);
  }

  Future<void> setActive(SvgAsset asset, bool value) =>
      update(asset.copyWith(isActive: value));

  Future<void> delete(SvgAsset asset) async {
    if (SupabaseConfig.isDemoMode) {
      MockDb.instance.svgAssets.removeWhere((e) => e.id == asset.id);
      return;
    }
    final client = SupabaseConfig.client;
    if (asset.filePath.isNotEmpty) {
      await client.storage
          .from(SupabaseConfig.svgBucket)
          .remove([asset.filePath]);
    }
    await client.from('svg_assets').delete().eq('id', asset.id);
  }
}
