import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/viewmodels/user_viewmodel.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);

    return Drawer(

      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // HEADER
          UserAccountsDrawerHeader(
            accountName: Text(
              userVM.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            accountEmail: Text(
              userVM.email,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
              ),
            ),

            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
          ),

          // MENU ITEMS

          drawerItem(
            context,
            icon: Icons.backup,
            title: "Backup/Restore",
            route: '/backup',
          ),

          drawerItem(
            context,
            icon: Icons.share,
            title: "Share With Friends",
            route: '/share',
          ),

          drawerItem(
            context,
            icon: Icons.star_border,
            title: "Rate Us",
            route: '/rate',
          ),

          drawerItem(
            context,
            icon: Icons.bar_chart,
            title: "Report/Support",
            route: '/support',
          ),

          drawerItem(
            context,
            icon: Icons.settings,
            title: "Settings",
            route: '/settings',
          ),

          drawerItem(
            context,
            icon: Icons.person_outline,
            title: "User Profile",
            route: '/profile',
          ),

          drawerItem(
            context,
            icon: Icons.shopping_cart_outlined,
            title: "Subscribe",
            route: '/subscribe',
          ),

          drawerItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Data Privacy Declaration",
            route: '/privacy',
          ),

          drawerItem(
            context,
            icon: Icons.logout,
            title: "Logout",
            route: '/logout',
          ),

          drawerItem(
            context,
            icon: Icons.delete_outline,
            title: "Delete Account",
            route: '/delete',
          ),
        ],
      ),
    );
  }

  Widget drawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String route,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}