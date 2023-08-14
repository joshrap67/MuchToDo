import 'package:flutter/material.dart';
import 'package:much_todo/src/rooms/rooms_list.dart';
import 'package:much_todo/src/providers/settings_provider.dart';
import 'package:much_todo/src/settings/settings.dart';
import 'package:much_todo/src/task_list/task_list.dart';
import 'package:much_todo/src/utils/utils.dart';

class Home extends StatefulWidget {
  final SettingsProvider controller;

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
    _screens = <Widget>[const TaskList(), const RoomList(), Settings(controller: widget.controller)];
    _navStack.add(_selectedIndex);
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
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.sticky_note_2_rounded), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Rooms'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
          ],
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          elevation: 12.0,
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
    setState(() {
      _selectedIndex = index;
      _navStack.insert(0, index);
      switchPages(index);
    });
  }

  void switchPages(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.ease);
    hideKeyboard();
  }
}
