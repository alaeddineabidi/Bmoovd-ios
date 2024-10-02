import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:bmoovd/screens/Shop/Details.dart';
import 'package:bmoovd/screens/Shop/cart.dart';
import 'package:bmoovd/widgets/BottomNavigationBar.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopMainPage extends StatefulWidget {
  @override
  _ShopMainPageState createState() => _ShopMainPageState();
}

class _ShopMainPageState extends State<ShopMainPage> {
  List<String> cart = [];
  String? userId;
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _updateCartItemCount();
  }

  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  Future<void> _updateCartItemCount() async {
    if (userId == null) return;

    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    setState(() {
      cartItemCount = cartSnapshot.docs.length;
    });
  }

  Future<void> _addProductsToFirestore() async {
    final storageRef = FirebaseStorage.instance.ref();
    final ListResult result = await storageRef.listAll();

    for (var item in result.items) {
      String imageUrl = await item.getDownloadURL();
      double price = _generateRandomPrice();
      String name = item.name.split('.').first;

      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'image': item.fullPath,
        'imageUrl': imageUrl,
      });
    }

    print('Produits ajoutés avec succès à Firestore!');
    setState(() {});
  }

  double _generateRandomPrice() {
    return (10 + (50 - 10) * (DateTime.now().millisecondsSinceEpoch % 100) / 100).toDouble();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    List<Map<String, dynamic>> products = [];
    for (var doc in snapshot.docs) {
      String imageUrl = await FirebaseStorage.instance
          .ref(doc['image'])
          .getDownloadURL();
      products.add({
        'id': doc.id,
        'name': doc['name'],
        'price': doc['price'],
        'imageUrl': imageUrl,
        'Description': doc["Description"]
      });
    }
    return products;
  }

  Future<void> _addToCart(String userId, String productId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').add({
      'productId': productId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _updateCartItemCount(); // Update cart item count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text(
              'Shop',
              style: GoogleFonts.plusJakartaSans(
                color: Color(0xFFE6E7E9),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          Badge(
            label: Text(
              cartItemCount.toString(), // Ensure this displays the correct count
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              icon: Image.asset('assets/icons/cart.png'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(),
                  ),
                );
              },
            ),
          ),
        ],
        toolbarHeight: 80,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF007C7C),));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ladefehler', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Kein Produkt gefunden', style: TextStyle(color: Colors.white)));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.75,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var product = snapshot.data![index];
              return LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(product: product),
                        ),
                      );
                    },
                    child: Container(
                      height: 300, // Hauteur fixe de la Card augmentée
                      child: Card(
                        color: Colors.grey[900],
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(color: Colors.transparent, width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                              child: Image.network(
                                product['imageUrl'],
                                fit: BoxFit.cover,
                                height: 350, // Ajuste la hauteur de l'image si nécessaire
                                width: double.infinity,
                              ),
                            ),
                            Expanded( // Dynamically occupy the remaining space
                              child: Container(
                                 width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
                                  border: Border.all(color: Color(0xFFE6E7E9), width: 0.01),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromRGBO(0, 124, 124, 0.10), // Vert pour le dégradé du bas
                                      Color(0xff122120), // Couleur verte plus foncée
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 17.0,
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0, left: 10),
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.0,
                                            color: Color(0xFFE6E7E9),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${product['price'].toStringAsFixed(2)}€',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFE6E7E9),
                                            fontSize: 12.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1, context: context),
    );
  }
}

class Badge extends StatelessWidget {
  final Widget child;
  final Widget label;

  Badge({required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(child: label),
          ),
        ),
      ],
    );
  }
}
