import 'dart:convert';

import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavedReadingState {
  final int discussionId;
  final DiscussionResponse response;
  final double scroll;

  SavedReadingState({required this.discussionId, required this.response, required this.scroll});
}

/// Persists the discussion the user is currently reading (raw API response + scroll offset)
/// so the reading position can be restored after the OS kills the app process.
/// The state is cleared when the user leaves the discussion normally.
class ReadingStateService {
  static final ReadingStateService _singleton = ReadingStateService._internal();
  late Box<dynamic> _box;
  final _discussionIdKey = 'discussionId';
  final _responseKey = 'response';
  final _scrollKey = 'scroll';

  factory ReadingStateService() {
    return _singleton;
  }

  ReadingStateService._internal();

  Future<ReadingStateService> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('readingState');
    return _singleton;
  }

  saveResponse(int discussionId, Map<String, dynamic>? rawResponse) {
    if (rawResponse == null) {
      return;
    }
    _box.putAll({_discussionIdKey: discussionId, _responseKey: jsonEncode(rawResponse), _scrollKey: 0.0});
  }

  appendPosts(int discussionId, List rawPosts) {
    if (_box.get(_discussionIdKey) != discussionId) {
      return;
    }
    try {
      Map<String, dynamic> response = jsonDecode(_box.get(_responseKey));
      (response['posts'] as List).addAll(rawPosts);
      _box.put(_responseKey, jsonEncode(response));
    } catch (error) {
      _box.clear();
    }
  }

  saveScroll(int discussionId, double pixels) {
    if (_box.get(_discussionIdKey) != discussionId) {
      return;
    }
    _box.put(_scrollKey, pixels);
  }

  SavedReadingState? load() {
    final discussionId = _box.get(_discussionIdKey);
    final response = _box.get(_responseKey);
    if (discussionId is! int || response is! String) {
      return null;
    }
    try {
      return SavedReadingState(
        discussionId: discussionId,
        response: DiscussionResponse.fromJson(jsonDecode(response)),
        scroll: _box.get(_scrollKey, defaultValue: 0.0),
      );
    } catch (error) {
      _box.clear();
      return null;
    }
  }

  clear(int discussionId) {
    if (_box.get(_discussionIdKey) == discussionId) {
      _box.clear();
    }
  }

  flush() {
    _box.clear();
  }
}
