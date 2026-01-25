import 'package:flutter/material.dart';
import 'package:sirana_milka/services/auth_service.dart';

class SidebarMenu extends StatelessWidget {
  final int selectedIndex;

  const SidebarMenu({super.key, required this.selectedIndex});

  Widget sidebarItem({
    required IconData icon,
    required String title,
    required int index,
    required BuildContext context,
    required String routeName,
  }) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        if (selectedIndex != index) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffACD6F2) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? const Color(0xff016CB5) : Colors.black),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? const Color(0xff016CB5) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('Login_Logo.png'),
          ),
          const SizedBox(height: 10),
          Text(
           'Bok, ${TokenHelper.getNameFromToken(AuthService.token ?? "") ?? "Korisnik"}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff034C7D),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          sidebarItem(context: context, icon: Icons.dashboard, title: "Nadzorna ploča", index: 0, routeName: '/dashboard'),
          const SizedBox(height: 5),
          sidebarItem(context: context, icon: Icons.storage, title: "Skladište", index: 1, routeName: '/storage'),
          const SizedBox(height: 5),
          sidebarItem(context: context, icon: Icons.people, title: "Partneri", index: 2, routeName: '/partners'),
          const SizedBox(height: 5),
          sidebarItem(context: context, icon: Icons.list_alt, title: "Narudžbe", index: 4, routeName: '/orders'),
          const SizedBox(height: 5),
          sidebarItem(context: context, icon: Icons.money, title: "Financije", index: 5, routeName: '/finance'),
          const SizedBox(height: 5),
          sidebarItem(context: context, icon: Icons.logout, title: "Odjava", index: 6, routeName: '/'),
        ],
      ),
    );
  }
}