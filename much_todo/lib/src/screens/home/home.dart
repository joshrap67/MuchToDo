import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/room_list/rooms_list.dart';
import 'package:much_todo/src/providers/settings_provider.dart';
import 'package:much_todo/src/screens/more_screen/more_screen.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/screens/task_list/task_list.dart';
import 'package:much_todo/src/utils/utils.dart';

class Home extends StatefulWidget {
  final SettingsProvider controller;

  static const routeName = '/home';

  const Home({super.key, required this.controller});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  List<Widget> _screens = [];
  final List<int> _navStack = <int>[];

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[const TaskList(), const RoomList(), MoreScreen(controller: widget.controller)];
    _navStack.add(_selectedIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserService.loadUser(context);
      RoomsService.getAllRooms(context);
      TaskService.getAllTasks(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackButton,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
        ),
        resizeToAvoidBottomInset: true,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.sticky_note_2_outlined),
              selectedIcon: Icon(Icons.sticky_note_2_rounded),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.room_outlined), // todo MeetingRoom icon instead?
              selectedIcon: Icon(Icons.room),
              label: 'Rooms',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: onItemTapped,
          elevation: 15,
          surfaceTintColor: const Color(0x00000000),
        ),
      ),
    );
  }

  Future<bool> handleBackButton() async {
    if (_navStack.length <= 1) {
      return true;
    } else {
      setState(() {
        _navStack.removeAt(0);
        _selectedIndex = _navStack[0];
        switchPages(_selectedIndex);
      });
      return false;
    }
  }

  void onItemTapped(int index) {
    if (index != 0) {
      // home is always at bottom of the stack
      _navStack.removeWhere((element) => element == index);
      _navStack.insert(0, index);
    }

    setState(() {
      switchPages(index);
      _selectedIndex = index;
    });
  }

  void switchPages(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.ease);
    hideKeyboard();
  }
}
