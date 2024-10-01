import 'package:bmoovd/screens/HomeScreen/HomeScreen.dart';
import 'package:bmoovd/screens/Shop/main_shop_screen.dart';
import 'package:bmoovd/screens/autres/autres.dart';
import 'package:bmoovd/screens/chat_with_IA/ia_chat.dart';
import 'package:bmoovd/screens/game/predictionScore.dart';
import 'package:bmoovd/widgets/LoginDialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  void _onItemTapped(int index) {
    User? user = FirebaseAuth.instance.currentUser;

    if (index == 2) {
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Predictionscore()),
          (Route<dynamic> route) => false, 
        );
      } else {
        DialogHelper.showLoginDialog(context);
      }
    } else if (index == 1) {
      
         Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ShopMainPage()),
          (Route<dynamic> route) => false, 
        );
     
    } else if (index == 0) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false, 
        );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatBotPage()),
      );
    } else if (index == 4) {
       Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Andere()),
          (Route<dynamic> route) => false, 
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        _buildNavItem("assets/icons/Home.png", "Home", 0, const Color(0xFFFABB48)),
        _buildNavItem("assets/icons/Bag.png", "Shop", 1, const Color(0xFF007C7C)),
        _buildNavItem("assets/icons/Gamepad.png", "Spiel", 2, const Color(0xFF91306A)),
        _buildNavItem("assets/icons/Chat.png", "Chat", 3, const Color(0xFF5A96F5)),
        _buildNavItem("assets/icons/Other.png", "Profile", 4, const Color(0xFFE6E7E9)),
      ],
      currentIndex: currentIndex,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.normal,
        fontSize: 12,
        color: _getSelectedLabelColor(currentIndex), // Utilise la fonction pour obtenir la couleur spécifique
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.normal,
        color: const Color(0xFF808080),
        fontSize: 12,
      ),
      selectedItemColor: _getSelectedLabelColor(currentIndex), // Définit la couleur de l'icône également
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      
      type: BottomNavigationBarType.fixed,
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label, int index, Color selectedColor) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: currentIndex == index ? selectedColor : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Image.asset(
          iconPath,
          color: currentIndex == index ? selectedColor : Colors.grey,
          width: 24,
          height: 24,
        ),
      ),
      label: label,
    );
  }

  Color _getSelectedLabelColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFABB48);
      case 1:
        return const Color(0xFF007C7C);
      case 2:
        return const Color(0xFF91306A);
      case 3:
        return const Color(0xFF5A96F5);
      case 4:
        return const Color(0xFFE6E7E9);
      default:
        return const Color(0xFF808080);
    }
  }
}
