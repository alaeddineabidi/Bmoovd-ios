import 'package:bmoovd/widgets/LoginDialog.dart';
import 'package:bmoovd/widgets/Sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailsPage({required this.product});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1; // Quantité initiale
  String? _selectedSize; // Taille sélectionnée

  Future<void> _addToCart(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .add({
        'productId': widget.product['id'],
        'name': widget.product['name'],
        'price': widget.product['price'],
        'imageUrl': widget.product['imageUrl'],
        'quantity': _quantity, // Ajouter la quantité
        'size': _selectedSize ?? 'N/A', // Ajouter la taille si sélectionnée
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product['name']} a été ajouté au panier!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour ajouter des articles au panier.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isClothing = widget.product['name'].toLowerCase() == 'tschirt' || widget.product['name'].toLowerCase() == 'pullover';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: Image.network(
                      widget.product['imageUrl'],
                      height: 350.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    widget.product['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE6E7E9),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.product['price'].toStringAsFixed(2)} €',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30.0,
                          color: Color(0xFFE6E7E9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Ajouter les boutons + et - et la quantité au milieu
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_quantity > 1) _quantity--;
                              });
                            },
                            icon: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFF69696d),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Icon(Icons.remove, color: Colors.white)),
                          ),
                          Text(
                            '$_quantity',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFF69696d),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Icon(Icons.add, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),

                  // Afficher les tailles uniquement si le produit est un vêtement (tshirt ou pullover)
                  if (isClothing)
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: Center(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSize = "SM";
                                });
                              },
                              child: Sizes(
                                text: "SM",
                                isSelected: _selectedSize == "SM",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSize = "M";
                                });
                              },
                              child: Sizes(
                                text: "M",
                                isSelected: _selectedSize == "M",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSize = "L";
                                });
                              },
                              child: Sizes(
                                text: "L",
                                isSelected: _selectedSize == "L",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSize = "XL";
                                });
                              },
                              child: Sizes(
                                text: "XL",
                                isSelected: _selectedSize == "XL",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user==null){
                              DialogHelper.showLoginDialog(context);
                            }else{
                              _addToCart(context);
                            }
                        }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(153, 0, 124, 124),
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'in den Warenkorb legen',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.0,
                          color: Color(0xFFE6E7E9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16.0,
              left: 16.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(153, 0, 124, 124), // Couleur de fond noire
                    shape: BoxShape.circle, // Forme arrondie
                  ),
                  padding: EdgeInsets.all(8.0), // Espacement intérieur pour l'image
                  child: Image.asset(
                    'assets/icons/back_arrow.png', // Remplacez par le chemin de votre image
                    height: 24.0,
                    width: 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
