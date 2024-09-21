import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalAmount = 0.0;
  List<Map<String, dynamic>> cartItems = [];
  bool isChecked = false; // Nouveau booléen pour la case à cocher

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  Future<void> _calculateTotal() async {
    double total = 0.0;
    List<Map<String, dynamic>> items = [];
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(doc['productId'])
          .get();

      // Get the price from Firestore and handle the type conversion
      dynamic priceField = productSnapshot['price'];
      double price = (priceField is String) ? double.parse(priceField) : priceField.toDouble();

int quantity = (doc.data() as Map<String, dynamic>).containsKey('quantity') 
    ? doc['quantity'] 
    : 1;

      double itemTotal = price * quantity;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String size = data.containsKey('size') ? data['size'] : 'N/A';

      total += itemTotal;
      items.add({
        "name": productSnapshot['name'],
        "quantity": quantity,
        "price": price.toStringAsFixed(2),
        "currency": "USD",
        "itemTotal": itemTotal.toStringAsFixed(2),
        "size": size,
      });
    }

    // Si la case est cochée, ajouter 1 euro au total
    if (isChecked) {
      total += 1.0;
    }

    setState(() {
      totalAmount = total;
      cartItems = items;
    });
  }

  Future<void> _deleteFromCart(String cartItemId) async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .doc(cartItemId)
        .delete();
    _calculateTotal(); // Recalculate total after deletion
  }

  Future<void> _updateQuantity(String cartItemId, int newQuantity) async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .doc(cartItemId)
        .update({
      'quantity': newQuantity,
    });
    _calculateTotal(); // Recalculer le total après la modification de la quantité
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Mein Warenkorb', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Image.asset("assets/icons/back_arrow.png")),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Ladefehler.',
                    style: GoogleFonts.poppins(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('Ihr Warenkorb ist leer.',
                    style: GoogleFonts.poppins(color: Colors.white)));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var cartItem = snapshot.data!.docs[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .doc(cartItem['productId'])
                          .get(),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                              title: Text('Laden...',
                                  style: GoogleFonts.poppins(color: Colors.white)));
                        }
                        if (productSnapshot.hasError) {
                          return ListTile(
                              title: Text('Ladefehler',
                                  style: TextStyle(color: Colors.white)));
                        }
                        var product = productSnapshot.data!;
                       Map<String, dynamic>? data = cartItem.data() as Map<String, dynamic>?;

int quantity = data != null && data.containsKey('quantity') ? data['quantity'] : 1;



                        double itemTotal = (product['price'] is String
                            ? double.parse(product['price'])
                            : product['price'].toDouble()) * quantity;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    child: Image.network(product['imageUrl']),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        // Prix du produit
                                        Text(
                                          '€ ${itemTotal.toStringAsFixed(2)}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Color(0xFFE6E7E9),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                if (quantity > 1) {
                                                  _updateQuantity(cartItem.id, quantity - 1);
                                                }
                                              },
                                              icon: Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xFF2C2C2C),
                                                    borderRadius: BorderRadius.circular(6)),
                                                child: Icon(Icons.remove, color: Colors.white),
                                              ),
                                            ),
                                            Text(
                                              '$quantity',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 20.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _updateQuantity(cartItem.id, quantity + 1);
                                              },
                                              icon: Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xFF2C2C2C),
                                                    borderRadius: BorderRadius.circular(6)),
                                                child: Icon(Icons.add, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Bouton de suppression
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 51.0),
                                    child: IconButton(
                                      icon: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Color(0xFFE6E7E9)),
                                            borderRadius: BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            Icons.close,
                                            size: 15,
                                            color: Color(0xFFE6E7E9),
                                          ),
                                        ),
                                      ),
                                      onPressed: () => _deleteFromCart(cartItem.id),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Case à cocher
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      focusColor:Color(0xFFE6E7E9),
                      checkColor: Color(0xFF15161A),
                      activeColor: Color(0xFFE6E7E9),
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                        _calculateTotal(); // Recalculer le total quand la case change
                      },
                    ),
                    Expanded(
                      child: Text(
                        "Hilf mit einem zusätzlichen Euro, um 'Schenke ein Lächeln' zu unterstützen – danke für deinen Beitrag!",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gesamt: ',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0,
                                color: Color(0xFF808080),
                                )),
                        Text('€${totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0,
                                color: Color(0xFFCFCFCF))),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => PaypalCheckout(
                            sandboxMode: true,
                            clientId: "AcL6mST4Fw1C0rcmQzp_I0jmJHsMwQQ9LOpmRzEVfKsmNDLHyHz9OUCsI0dvhx5xxv_F6lOtPQLgvgyH",
                            secretKey: "ELwRY4t0oEmwGzzRFciSvPx4mV4UD5Eu_ZRkFRTBQ-JvqU0qtr9Q1H7NkgXLbOZwGz_VZ3-E8oZX0gtV",
                            returnURL: "success.snippetcoder.com",
                            cancelURL: "cancel.snippetcoder.com",
                            transactions: [
                              {
                                "amount": {
                                  "total": totalAmount.toStringAsFixed(2),
                                  "currency": "EUR",
                                  "details": {
                                    "subtotal": totalAmount.toStringAsFixed(2),
                                    "shipping": '0',
                                    "shipping_discount": 0
                                  }
                                },
                                "description": "The payment transaction description.",
                                "item_list": {
                                  "items": cartItems.map((item) {
                                    return {
                                      "name": item["name"],
                                      "quantity": item["quantity"].toString(),
                                      "price": item["price"],
                                      "currency": "USD"
                                    };
                                  }).toList()
                                }
                              }
                            ],
                            note: "Contact us for any questions on your order.",
                            onSuccess: (Map params) async {
                              print("onSuccess: $params");
                            },
                            onError: (error) {
                              print("onError: $error");
                            },
                            onCancel: () {
                              print('cancelled:');
                            },
                          ),
                        ));
                      },
                      child: Center(
                          child: Text('Zahlen',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 20,
                                  fontWeight: FontWeight.bold,color: Color(0xFF15161A)))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE6E7E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: Size(double.infinity, 60.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
