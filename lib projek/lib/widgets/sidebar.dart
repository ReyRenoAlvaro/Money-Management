import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _createDrawerItem(
            icon: Icons.home,
            text: 'Home',
            onTap: () => Navigator.pushNamed(context, '/'),
          ),
          _createDrawerItem(
            icon: Icons.attach_money,
            text: 'Income',
            onTap: () => Navigator.pushNamed(context, '/income'),
          ),
          _createDrawerItem(
            icon: Icons.money_off,
            text: 'Expense',
            onTap: () => Navigator.pushNamed(context, '/expense'),
          ),
          _createDrawerItem(
            icon: Icons.category,
            text: 'Income Categories',
            onTap: () => Navigator.pushNamed(context, '/income-category'),
          ),
          _createDrawerItem(
            icon: Icons.category_outlined,
            text: 'Expense Categories',
            onTap: () => Navigator.pushNamed(context, '/expense-category'),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
