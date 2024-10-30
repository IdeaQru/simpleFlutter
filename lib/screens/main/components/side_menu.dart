import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../maps/maps_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Modifikasi DrawerHeader untuk berisi teks
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Tambahkan warna latar belakang jika diinginkan
            ),
            child: Center(
              child: Text(
                "SISTEM MONITORING POSISI TERINTEGRASI DENGAN PETA LAUT ",
                style: TextStyle(
                  color: Colors.white, // Warna teks
                  fontSize: 24,        // Ukuran font
                  fontWeight: FontWeight.bold, // Gaya font
                ),
              ),
            ),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Maps",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapsScreen(), // Panggil MapsScreen
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
