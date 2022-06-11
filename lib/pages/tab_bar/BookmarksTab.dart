import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/components/NotificationBadge.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/BookmarkedDiscussion.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/TabsEnum.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:provider/provider.dart';

class BookmarksTab extends StatefulWidget {
  // Unread filter toggle
  final bool filterUnread;

  final int refreshTimestamp;

  const BookmarksTab({Key? key, this.filterUnread = false, this.refreshTimestamp = 0}) : super(key: key);

  @override
  State<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<BookmarksTab> {
  late PageController _bookmarksController;
  bool _filterUnread = false;

  TabsEnum activeTab = TabsEnum.history;
  List<int> _toggledCategories = [];
  int _refreshData = 0;

  @override
  void initState() {
    _filterUnread = widget.filterUnread;

    final defaultView =
        MainRepository().settings.defaultView == DefaultView.latest ? MainRepository().settings.latestView : MainRepository().settings.defaultView;

    activeTab = [DefaultView.history, DefaultView.historyUnread].indexOf(defaultView) >= 0 ? TabsEnum.history : TabsEnum.bookmarks;
    if (activeTab == TabsEnum.bookmarks) {
      _bookmarksController = PageController(initialPage: 1);
    } else {
      _bookmarksController = PageController(initialPage: 0);
    }

    _bookmarksController.addListener(() {
      // If the CupertinoTabView is sliding and the animation is finished, change the active tab
      if (_bookmarksController.page! % 1 == 0 && activeTab != TabsEnum.values[_bookmarksController.page!.toInt()]) {
        setState(() {
          activeTab = TabsEnum.values[_bookmarksController.page!.toInt()];
        });
      }
    });

    super.initState();
  }

  // isInverted
  // Sometimes the activeTab var is changed after the listener where we call updateLatestView() finishes.
  // Therefore, the var activeTab needs to be handled as inverted.
  void updateLatestView({bool isInverted: false}) {
    DefaultView latestView = activeTab == TabsEnum.history ? DefaultView.history : DefaultView.bookmarks;
    if (isInverted) {
      latestView = activeTab == TabsEnum.history ? DefaultView.bookmarks : DefaultView.history;
    }

    if (_filterUnread) {
      latestView = latestView == DefaultView.bookmarks ? DefaultView.bookmarksUnread : DefaultView.historyUnread;
    }
    MainRepository().settings.latestView = latestView;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.filterUnread != widget.filterUnread) {
      setState(() {
        _filterUnread = widget.filterUnread;
        _toggledCategories = [];
        _refreshData = DateTime.now().millisecondsSinceEpoch;
      });
      this.updateLatestView();
    } else if (widget.refreshTimestamp > oldWidget.refreshTimestamp) {
      setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
    }
  }

  @override
  void dispose() {
    _bookmarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Consumer<NotificationsModel>(
                builder: (context, notifications, child) => NotificationBadge(
                    widget: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: kMinInteractiveDimensionCupertino - 10,
                        child: Icon(
                          Icons.notifications_none,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed('/notices')),
                    isVisible: notifications.newNotices > 0,
                    counter: notifications.newNotices)),
            middle: CupertinoSegmentedControl(
              groupValue: activeTab,
              onValueChanged: (value) {
                _bookmarksController.animateToPage(TabsEnum.values.indexOf(value as TabsEnum),
                    duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
              children: {
                TabsEnum.history: Padding(
                  child: Text('Historie'),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                TabsEnum.bookmarks: Padding(
                  child: Text('Sledované'),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              },
            )),
        child: PageView(
          controller: _bookmarksController,
          onPageChanged: (int index) => this.updateLatestView(isInverted: true),
          pageSnapping: true,
          children: <Widget>[
            // -----
            // HISTORY PULL TO REFRESH
            // -----
            PullToRefreshList(
                rebuild: _refreshData,
                dataProvider: (lastId) async {
                  List<DiscussionListItem> withReplies = [];
                  var result = await ApiController().loadHistory();
                  var data = result.discussions
                      .map((discussion) => BookmarkedDiscussion.fromJson(discussion))
                      .where((discussion) => this._filterUnread ? discussion.unread > 0 : true)
                      .map((discussion) => DiscussionListItem(discussion))
                      .where((discussionListItem) {
                    if (discussionListItem.discussion.replies > 0) {
                      withReplies.add(discussionListItem);
                      return false;
                    }
                    return true;
                  }).toList();
                  data.insertAll(0, withReplies);
                  return DataProviderResult(data);
                }),
            // -----
            // BOOKMARKS PULL TO REFRESH
            // -----
            PullToRefreshList(
                rebuild: _refreshData,
                dataProvider: (lastId) async {
                  var categories = [];
                  var result = await ApiController().loadBookmarks();

                  result.bookmarks.forEach((_bookmark) {
                    List<DiscussionListItem> withReplies = [];
                    var discussion = _bookmark.discussions
                        .where((discussion) {
                          // Filter by tapping on category headers
                          // If unread filter is ON
                          if (this._filterUnread) {
                            if (_toggledCategories.indexOf(_bookmark.categoryId) >= 0) {
                              // If unread filter is ON and category toggle is ON, display discussions
                              return true;
                            } else {
                              // If unread filter is ON and category toggle is OFF, display unread discussions only
                              return discussion.unread > 0;
                            }
                          } else {
                            if (_toggledCategories.indexOf(_bookmark.categoryId) >= 0) {
                              // If unread filter is OFF and category toggle is ON, hide discussions
                              return false;
                            }
                          }
                          // If unread filter is OFF and category toggle is OFF, show discussions
                          return true;
                        })
                        .map((discussion) => DiscussionListItem(discussion))
                        .where((discussionListItem) {
                          if (discussionListItem.discussion.replies > 0) {
                            withReplies.add(discussionListItem);
                            return false;
                          }
                          return true;
                        })
                        .toList();
                    discussion.insertAll(0, withReplies);
                    categories.add({
                      'header': ListHeader(_bookmark.categoryName, onTap: () {
                        if (_toggledCategories.indexOf(_bookmark.categoryId) >= 0) {
                          // Hide discussions in the category
                          setState(() => _toggledCategories.remove(_bookmark.categoryId));
                        } else {
                          // Show discussions in the category
                          setState(() => _toggledCategories.add(_bookmark.categoryId));
                        }
                        setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
                      }),
                      'items': discussion
                    });
                  });
                  return DataProviderResult(categories);
                }),
          ],
        ),
      );
    });
  }
}
