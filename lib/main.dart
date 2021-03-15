import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/AuthService.dart';
import 'package:nova_green/SignIn.dart';
import 'package:nova_green/pages/Cart.dart';
import 'package:nova_green/pages/Home.dart';
import 'package:nova_green/pages/Liked.dart';
import 'package:nova_green/pages/News.dart';
import 'package:nova_green/pages/Profile.dart';
import 'package:provider/provider.dart';

final storageRef = FirebaseStorage.instance.ref();
final sellersRef = FirebaseFirestore.instance.collection('sellers');
final productsRef = FirebaseFirestore.instance.collection('products');
final cartRef = FirebaseFirestore.instance.collection('carts');
final likedRef = FirebaseFirestore.instance.collection('liked');
final postsRef = FirebaseFirestore.instance.collection('posts');
final savedRef = FirebaseFirestore.instance.collection('saved');
final commentRef = FirebaseFirestore.instance.collection('comments');
final addressRef = FirebaseFirestore.instance.collection('addresses');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance)),
        StreamProvider(
            create: (context) => context.read<AuthService>().authStateChanges)
      ],
      child: MaterialApp(
        title: 'NOVA green',
        theme: ThemeData(
          appBarTheme:
              AppBarTheme(iconTheme: IconThemeData(color: Colors.black)),
          fontFamily: 'Ubuntu',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();

    if (_firebaseUser != null) {
      print(_firebaseUser.displayName);
      print(_firebaseUser.email);
      print(_firebaseUser.photoURL);
      print(_firebaseUser.uid);
      return MainScreen(user: _firebaseUser);
    }
    return SignIn();
  }
}

class MainScreen extends StatefulWidget {
  final User user;

  MainScreen({Key key, title, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentPageIndex = 4;
  final List<Widget> pages = [];
  PageController _pageController;
  bool isDrawerOpen = false;
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _scaleAnimation;

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(_controller);
    pages.add(Home());
    pages.add(Cart());
    pages.add(Liked());
    pages.add(News());
    pages.add(Profile());
    _pageController = PageController(initialPage: 4, keepPage: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget menu(IconData unSelected, IconData selected, String title, int index) {
    bool _isSelected = _currentPageIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentPageIndex = index;
          if (isDrawerOpen) {
            xOffset = 0;
            yOffset = 0;
            scaleFactor = 1;
            _controller.reverse();
            isDrawerOpen = !isDrawerOpen;
          }
        });
        _pageController.jumpToPage(index);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            _isSelected
                ? Icon(selected, color: Colors.white)
                : Icon(unSelected, color: Colors.white60),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                  color: _isSelected ? Colors.white : Colors.white60,
                  fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xFF226F54),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 30,
                        backgroundImage: NetworkImage(widget.user.photoURL),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.user.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          menu(Icons.home_outlined, Icons.home, 'Home', 0),
                          menu(Icons.shopping_bag_outlined, Icons.shopping_bag,
                              'Cart', 1),
                          menu(Icons.favorite_border, Icons.favorite, 'Liked',
                              2),
                          menu(Icons.pages_outlined, Icons.pages, 'News', 3),
                          menu(Icons.account_circle_outlined,
                              Icons.account_circle, 'Profile', 4),
                          SizedBox(height: 80)
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: InkWell(
                    onTap: () async {
                      await context.read<AuthService>().signOut();
                    },
                    child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        title: Text('Logout',
                            style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          transform: Matrix4.translationValues(xOffset, yOffset, 0)
            ..scale(scaleFactor),
          decoration: BoxDecoration(
              borderRadius: isDrawerOpen
                  ? BorderRadius.all(Radius.circular(40))
                  : BorderRadius.zero),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isDrawerOpen) {
                  xOffset = 0;
                  yOffset = 0;
                  scaleFactor = 1;
                  _controller.reverse();
                  isDrawerOpen = !isDrawerOpen;
                }
              });
            },
            child: Scaffold(
              body: Stack(
                children: [
                  PageView(
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: pages,
                  ),
                  Positioned(
                      top: 40,
                      left: 10,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isDrawerOpen) {
                              xOffset = 0;
                              yOffset = 0;
                              scaleFactor = 1;
                              _controller.reverse();
                            } else {
                              xOffset = 230;
                              yOffset = 150;
                              scaleFactor = 0.6;
                              _controller.forward();
                            }
                            isDrawerOpen = !isDrawerOpen;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                                isDrawerOpen
                                    ? Icons.arrow_back_ios_rounded
                                    : Icons.menu,
                                color: Colors.black87)),
                      ))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
//
// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bottom Navigation Bar',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: App(),
//     );
//   }
// }
//
// class TabItem {
//   final String tabName;
//   final IconData icon;
//   final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
//   int _index = 0;
//   Widget _page;
//
//   TabItem({
//     @required this.tabName,
//     @required this.icon,
//     @required Widget page,
//   }) {
//     _page = page;
//   }
//
//   void setIndex(int i) {
//     _index = i;
//   }
//
//   int getIndex() => _index;
//
//   Widget get page {
//     return Visibility(
//       visible: _index == AppState.currentTab,
//       maintainState: true,
//       child: Navigator(
//         key: key,
//         onGenerateRoute: (routeSettings) {
//           return MaterialPageRoute(
//             builder: (_) => _page,
//           );
//         },
//       ),
//     );
//   }
// }
//
// class App extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => AppState();
// }
//
// class AppState extends State<App> {
//   static int currentTab = 0;
//
//   final List<TabItem> tabs = [
//     TabItem(
//       tabName: "Home",
//       icon: Icons.home,
//       page: HomeScreen(),
//     ),
//     TabItem(
//       tabName: "Settings",
//       icon: Icons.settings,
//       page: SettingsScreen(),
//     ),
//   ];
//
//   AppState() {
//     tabs.asMap().forEach((index, details) {
//       details.setIndex(index);
//     });
//   }
//
//   void _selectTab(int index) {
//     if (index == currentTab) {
//       tabs[index].key.currentState.popUntil((route) => route.isFirst);
//     } else {
//       setState(() => currentTab = index);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         final isFirstRouteInCurrentTab =
//             !await tabs[currentTab].key.currentState.maybePop();
//         if (isFirstRouteInCurrentTab) {
//           if (currentTab != 0) {
//             _selectTab(0);
//             return false;
//           }
//         }
//         return isFirstRouteInCurrentTab;
//       },
//       child: Scaffold(
//         body: IndexedStack(
//           index: currentTab,
//           children: tabs.map((e) => e.page).toList(),
//         ),
//         bottomNavigationBar: BottomNavigation(
//           onSelectTab: _selectTab,
//           tabs: tabs,
//         ),
//       ),
//     );
//   }
// }
//
// class BottomNavigation extends StatelessWidget {
//   BottomNavigation({
//     this.onSelectTab,
//     this.tabs,
//   });
//
//   final ValueChanged<int> onSelectTab;
//   final List<TabItem> tabs;
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       items: tabs
//           .map(
//             (e) => _buildItem(
//               index: e.getIndex(),
//               icon: e.icon,
//               tabName: e.tabName,
//             ),
//           )
//           .toList(),
//       onTap: (index) => onSelectTab(
//         index,
//       ),
//     );
//   }
//
//   BottomNavigationBarItem _buildItem(
//       {int index, IconData icon, String tabName}) {
//     return BottomNavigationBarItem(
//       icon: Icon(
//         icon,
//         color: _tabColor(index: index),
//       ),
//       title: Text(
//         tabName,
//         style: TextStyle(
//           color: _tabColor(index: index),
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
//
//   Color _tabColor({int index}) {
//     return AppState.currentTab == index ? Colors.cyan : Colors.grey;
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: MaterialButton(
//         child: Text("Open Secondary page"),
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => NewPage(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class SettingsScreen extends StatelessWidget {
//   final Function openSettings;
//
//   const SettingsScreen({Key key, this.openSettings}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: FlatButton(
//         child: Text("Push other Settings"),
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => NewPage(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class NewPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'New Screen',
//         ),
//       ),
//       body: Container(
//         child: FlatButton(
//           child: Text("Push new Screen"),
//           onPressed: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => NewPage(),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
