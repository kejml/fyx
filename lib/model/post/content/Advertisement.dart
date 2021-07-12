import 'package:fyx/model/FileAttachment.dart';
import 'package:fyx/model/UserReferences.dart';
import 'package:fyx/model/enums/AdEnums.dart';
import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/content/Regular.dart';

class ContentAdvertisement extends Content {
  ContentRegular contentRegular;

  int _discussion_id;
  String _full_name;
  List<int> _parent_categories;
  List<String> _photo_ids;
  String _ad_type;
  int _price;
  String _location;
  String _currency;
  String _state;
  String _summary;
  String _shipping;
  String _description;
  String _description_raw;
  int _refreshed_at;
  int _inserted_at;
  int _posts_count;
  List _parameters;
  List<FileAttachment> fileAttachments;
  UserReferences references;

  ContentAdvertisement.fromJson(Map<String, dynamic> json, {bool isCompact}) : super(PostTypeEnum.advertisement, isCompact: isCompact) {
    _discussion_id = json['discussion_id'];
    _full_name = json['full_name'] ?? '';
    _parent_categories = List.castFrom(json['parent_categories'] ?? []);
    _photo_ids = List.castFrom(json['photo_ids'] ?? []);
    _ad_type = json['ad_type'];
    _price = json['price'];
    _location = json['location'] ?? '';
    _currency = json['currency'] ?? '';
    _state = json['state'];
    _summary = json['summary'] ?? '';
    _shipping = json['shipping'] ?? '';
    _description = json['description'] ?? '';
    _description_raw = json['description_raw'] ?? '';
    _posts_count = json['posts_count'];
    _parameters = List.castFrom(json['parameters'] ?? []);

    try {
      _refreshed_at = DateTime.parse(json['refreshed_at']).millisecondsSinceEpoch;
    } catch (error) {
      _refreshed_at = 0;
    }

    try {
      _inserted_at = DateTime.parse(json['inserted_at']).millisecondsSinceEpoch;
    } catch (error) {
      _inserted_at = 0;
    }
  }

  factory ContentAdvertisement.fromDiscussionJson(Map<String, dynamic> json, {bool isCompact}) {
    ContentAdvertisement ad = ContentAdvertisement.fromJson(json['advertisement'], isCompact: isCompact);

    if (json['attachments'] is List) {
      ad.fileAttachments = List.castFrom<dynamic, Map<String, dynamic>>(json['attachments']).map((attachment) => FileAttachment.fromJson(attachment)).toList();
    }

    if (json['references'] is Map) {
      ad.references = UserReferences.fromJson(json['references']);
    }
    // TODO: other_ads, current_parameter_values, similar_ad_counts

    return ad;
  }

  factory ContentAdvertisement.fromPostJson(Map<String, dynamic> json, {bool isCompact}) {
    ContentAdvertisement ad = ContentAdvertisement.fromJson(json['content_raw']['data'], isCompact: isCompact);
    ad.contentRegular = ContentRegular(json['content']);
    return ad;
  }

  List get parameters => _parameters;

  int get postsCount => _posts_count;

  int get refreshedAt => _refreshed_at;

  String get summary => _summary;

  AdStateEnum get state {
    switch (_state) {
      case 'active': return AdStateEnum.active;
      case 'old': return AdStateEnum.old;
      case 'sold': return AdStateEnum.sold;
      default: return AdStateEnum.unknown;
    }
  }

  String get currency => _currency;

  String get location => _location;

  int get price => _price;

  AdTypeEnum get type => _ad_type == 'offer' ? AdTypeEnum.offer : AdTypeEnum.need;

  List<String> get photoIds => _photo_ids;

  List<int> get parentCategories => _parent_categories;

  String get fullName => _full_name;

  String get shipping => _shipping;

  int get discussionId => _discussion_id;

  ContentRegular get descriptionRaw => ContentRegular(_description_raw);

  ContentRegular get description => ContentRegular(_description);

  int get insertedAt => _inserted_at;
}
