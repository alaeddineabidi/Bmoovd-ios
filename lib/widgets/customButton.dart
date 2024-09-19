import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final String assetImage; // Image depuis les assets
  final Color startColor; // Couleur de début du dégradé
  final Color endColor;   // Couleur de fin du dégradé

  CustomButton({
    required this.text,
    required this.onPressed,
    required this.color,
    required this.assetImage, // Chemin de l'image dans les assets
    required this.startColor, // Couleur de début du dégradé
    required this.endColor,   // Couleur de fin du dégradé
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              gradient: RadialGradient(
                center: Alignment(0.085, 0.241), // Coordonnées du centre
                radius: 2.3788, // Rayon du dégradé
                colors: [
                  startColor, // Utilisation de la couleur de début
                  endColor,   // Utilisation de la couleur de fin
                ],
                stops: [0.302, 0.5], // Points de transition des couleurs
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Fond transparent pour voir le dégradé
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: Size(double.infinity, 100), // Assure que le bouton prend toute la hauteur du conteneur
                padding: EdgeInsets.zero, // Supprime le padding par défaut
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1, // Le texte prendra l'autre moitié de la largeur
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start, // Place le texte plus haut
                        crossAxisAlignment: CrossAxisAlignment.start, // Aligne le texte à gauche
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, left: 10.0,bottom:50), // Ajuste la position du texte
                            child: Text(
                              text,
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xFFE6E7E9),
                                fontSize: 12.8,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w700,
                                height: 18.773 / 12.8, // Hauteur de ligne relative
                                letterSpacing: -0.348,
                              ),
                              textAlign: TextAlign.start, // Centre le texte horizontalement
                              overflow: TextOverflow.visible, // Permet l'affichage sur plusieurs lignes
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1, // L'image prendra la moitié de la largeur
                      child: Image.asset(
                        assetImage,
                        width: double.infinity, // Assure que l'image occupe toute la largeur
                        height: 100, // Ajuste la hauteur pour correspondre au bouton
                        fit: BoxFit.cover, // Ajuste l'image pour qu'elle couvre la zone disponible
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
