import 'package:fyx/theme/L.dart';
import 'package:html/parser.dart';

enum INTERNAL_URI_PARSER { discussionId, postId }

class Helpers {
  static stripHtmlTags(String html) {
    final document = parse(html);
    return parse(document.body.text).documentElement.text.trim();
  }

  static String parseTime(int time) {
    var duration = Duration(seconds: ((DateTime.now().millisecondsSinceEpoch / 1000).floor() - time));
    if (duration.inSeconds <= 0) {
      return L.GENERAL_NOW;
    }
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    }
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    }
    if (duration.inHours < 24) {
      return '${duration.inHours}H';
    }
    if (duration.inDays < 30) {
      return '${duration.inDays}D';
    }

    var months = (duration.inDays / 30).round(); // Approx
    if (months < 12) {
      return '${months}M';
    }

    var years = (months / 12).round();
    return '${years}Y';
  }

  static Map<INTERNAL_URI_PARSER, int> parseDiscussionUri(String uri) {
    RegExp topicDeeplinkTest = new RegExp(r"^(\?l=topic;id=([0-9]+);wu=([0-9]+))|(/discussion/([0-9]+)/id/([0-9]+))$");
    Iterable<RegExpMatch> topicDeeplinkMatches = topicDeeplinkTest.allMatches(uri);
    if (topicDeeplinkMatches.length == 1) {
      int discussionId = int.parse(topicDeeplinkMatches.elementAt(0).group(2) ?? '0');
      int postId = int.parse(topicDeeplinkMatches.elementAt(0).group(3) ?? '0');
      if (discussionId == 0 && postId == 0) {
        discussionId = int.parse(topicDeeplinkMatches.elementAt(0).group(5) ?? '0');
        postId = int.parse(topicDeeplinkMatches.elementAt(0).group(6) ?? '0');
      }
      return {INTERNAL_URI_PARSER.discussionId: discussionId, INTERNAL_URI_PARSER.postId: postId};
    }
    return {};
  }
}