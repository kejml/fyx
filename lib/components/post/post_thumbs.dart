import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/avatar.dart';
import 'package:fyx/model/post/PostThumbItem.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostThumbs extends StatelessWidget {
  final List<PostThumbItem> items;
  final isNegative;
  final bool isHorizontal;

  PostThumbs(this.items, {this.isNegative = false, this.isHorizontal = true});

  horizontalLayout(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    var avatars = items
        .map((item) => Tooltip(
              message: item.username,
              waitDuration: Duration(milliseconds: 0),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 0),
                child: Avatar(
                  Helpers.avatarUrl(item.username),
                  size: 22,
                  isHighlighted: item.isHighlighted,
                ),
              ),
            ))
        .toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 5),
          child: Icon(
            isNegative ? Icons.thumb_down : Icons.thumb_up,
            size: 18,
            color: isNegative ? colors.danger : colors.success,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            items.length.toString(),
            style: TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          child: Wrap(children: avatars),
        )
      ],
    );
  }

  verticalLayout(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    var avatars = items
        .map((item) => Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 0),
              child: Column(
                children: [
                  Avatar(
                    Helpers.avatarUrl(item.username),
                    size: 62,
                    isHighlighted: item.isHighlighted,
                  ),
                  Text(item.username, style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ))
        .toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isNegative ? Icons.thumb_down : Icons.thumb_up,
              size: 32,
              color: isNegative ? colors.danger : colors.success,
            ),
            SizedBox(width: 4),
            Text(
              items.length.toString(),
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        SizedBox(height: 8),
        GridView.count(
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 2 / 3,
            crossAxisCount: 6,
            shrinkWrap: true,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            children: avatars),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) return horizontalLayout(context);
    return verticalLayout(context);
  }
}
