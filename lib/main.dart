import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(FyxApp());
}

class FyxApp extends StatelessWidget {
  final PageController _bookmarksController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Fyx',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: CupertinoSegmentedControl(
            onValueChanged: (value) => _bookmarksController.animateToPage(int.parse(value), duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
            children: {
              '0': Padding(child: Text('Historie'), padding: EdgeInsets.symmetric(horizontal: 16),),
              '1': Padding(child: Text('Sledovane'), padding: EdgeInsets.symmetric(horizontal: 16),),
            },
          )

        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bookmark),
                title: Text('Sledované'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.mail),
                title: Text('Posta'),
              ),
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(builder: (context) {
                  return CupertinoPageScaffold(
                    child: PageView(
                      controller: _bookmarksController,
                      pageSnapping: true,
                      children: <Widget>[
                        Container(color: Colors.red,),
                        Container(color: Colors.blue,)
                      ],
                    ),
                  );
                });
              case 1:
                return CupertinoTabView(builder: (context) {
                  return CupertinoPageScaffold(
                    child: Container(),
                  );
                });
              case 2:
                return CupertinoTabView(builder: (context) {
                  return CupertinoPageScaffold(
                    child: Container(),
                  );
                });
              default:
                throw Exception('Selected undefined tab');
            }
          },
        ),
      )
    );
  }
}
