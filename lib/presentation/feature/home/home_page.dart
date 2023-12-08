import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_event.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_page.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  late ClubsListBloc clubsListBloc;

  @override
  void initState() {
    clubsListBloc = GetIt.I();
    super.initState();
  }


  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if(index == 0){
      clubsListBloc.add(GetAllClubsEvent());
    }
    setState(() {
      _currentIndex = index;
    });
  }

  final _clubListPage = const ClubsPage();
  final _profilePage = const SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mafia')),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          _clubListPage,
          Container(),
          _profilePage,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.createClubPage);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
