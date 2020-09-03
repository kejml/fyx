import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/TextIcon.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:share/share.dart';

class ShareData {
  final String subject;
  final String body;
  final String link;

  ShareData({this.subject, this.body, this.link});
}

class PostActionSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String user;
  final int postId;
  final Function flagPostCallback;
  final ShareData shareData;

  PostActionSheet({Key key, this.user, this.postId, this.flagPostCallback, this.parentContext, this.shareData}) : super(key: key);

  @override
  _PostActionSheetState createState() => _PostActionSheetState();
}

class _PostActionSheetState extends State<PostActionSheet> {
  bool _reportIndicator = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
        actions: <Widget>[
          Visibility(
            visible: widget.shareData is ShareData,
            child: CupertinoActionSheetAction(
                child: TextIcon(L.POST_SHEET_COPY_LINK, icon: Icons.link),
                onPressed: () {
                  var data = ClipboardData(text: widget.shareData.link);
                  Clipboard.setData(data).then((_) {
                    PlatformTheme.success(L.TOAST_COPIED);
                    Navigator.pop(context);
                  });
                  AnalyticsProvider().logEvent('copyLink');
                }),
          ),
          Visibility(
            visible: widget.shareData is ShareData,
            child: CupertinoActionSheetAction(
                child: TextIcon(
                  L.POST_SHEET_SHARE,
                  icon: Icons.share,
                ),
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  Share.share(widget.shareData.body, subject: widget.shareData.subject, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                  Navigator.pop(context);
                  AnalyticsProvider().logEvent('shareSheet');
                }),
          ),
          Visibility(
            visible: widget.user != MainRepository().credentials.nickname,
            child: CupertinoActionSheetAction(
                child: TextIcon(
                  '${L.POST_SHEET_BLOCK} @${widget.user}',
                  icon: Icons.block,
                  iconColor: Colors.redAccent,
                ),
                isDestructiveAction: true,
                onPressed: () {
                  MainRepository().settings.blockUser(widget.user);
                  PlatformTheme.success(L.TOAST_USER_BLOCKED);
                  Navigator.of(context).pop();
                  AnalyticsProvider().logEvent('blockUser');
                }),
          ),
          CupertinoActionSheetAction(
              child: TextIcon(
                L.POST_SHEET_HIDE,
                icon: Icons.visibility_off,
                iconColor: Colors.redAccent,
              ),
              isDestructiveAction: true,
              onPressed: () {
                widget.flagPostCallback(widget.postId);
                PlatformTheme.success(L.TOAST_POST_HIDDEN);
                Navigator.pop(context);
                AnalyticsProvider().logEvent('hidePost');
              }),
          CupertinoActionSheetAction(
              child: TextIcon(
                _reportIndicator ? L.POST_SHEET_FLAG_SAVING : L.POST_SHEET_FLAG,
                icon: Icons.warning,
                iconColor: Colors.redAccent,
              ),
              isDestructiveAction: true,
              onPressed: () async {
                try {
                  setState(() => _reportIndicator = true);
                  await ApiController().sendMail('FYXBOT', 'Inappropriate post/mail report: ID $widget.postId by user @$widget.user.');
                  PlatformTheme.success(L.TOAST_POST_FLAGGED);
                } catch (error) {
                  PlatformTheme.error(L.TOAST_POST_FLAG_ERROR);
                } finally {
                  setState(() => _reportIndicator = false);
                  Navigator.pop(context);
                  AnalyticsProvider().logEvent('flagContent');
                }
              }),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text(L.GENERAL_CANCEL),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
  }
}
