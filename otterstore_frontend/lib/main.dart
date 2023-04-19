import 'api_service.dart';
import 'app_model.dart';
import 'cart_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtterStore',
      theme: _darkMode
          ? ThemeData.dark().copyWith(
              visualDensity: VisualDensity.adaptivePlatformDensity,
            )
          : ThemeData.light().copyWith(
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
      home: AppStorePage(
        onDarkModeToggle: (value) {
          setState(() {
            _darkMode = value;
          });
        },
      ),
    );
  }
}

class AppStorePage extends StatefulWidget {
  final ValueChanged<bool> onDarkModeToggle;

  AppStorePage({required this.onDarkModeToggle});

  @override
  _AppStorePageState createState() => _AppStorePageState();
}

class _AppStorePageState extends State<AppStorePage> {
  late Future<List<AppModel>> futureApps;
  final CartService _cartService = CartService();
  bool _darkMode = false;
  @override
  void initState() {
    super.initState();
    futureApps = fetchApps();
  }

  void _showCart(
      BuildContext context, AsyncSnapshot<List<AppModel>> snapshot) async {
    List<String> cart = await _cartService.getCart();
    List<AppModel> cartItems = cart
        .map((appId) {
          return snapshot.data!.firstWhereOrNull((app) => app.id == appId);
        })
        .where((app) => app != null)
        .cast<AppModel>()
        .toList();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Cart',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...cart.map((appId) {
                    AppModel? app = snapshot.data!
                        .firstWhereOrNull((app) => app.id == appId);
                    if (app != null) {
                      return ListTile(
                        leading: Image.network(
                            'http://localhost:3000/proxy/${Uri.encodeComponent(app.imageUrl)}'),
                        title: Text(app.title),
                        subtitle: Text(app.description),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _cartService.removeFromCart(app.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('${app.title} removed from cart')));
                            setState(() {
                              cart.remove(app.id);
                            });
                          },
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }).toList(),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement your checkout functionality here
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CheckoutPage(cartItems: cartItems)),
                        );
                      },
                      child: Text('Checkout'),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ));
          },
        );
      },
    ).then((_) {
      // Refresh the main UI when the cart is closed
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OtterStore'),
        actions: [
          Switch(
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              widget.onDarkModeToggle(value);
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              futureApps.then((appList) {
                _showCart(context,
                    AsyncSnapshot.withData(ConnectionState.done, appList));
              });
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<AppModel>>(
          future: futureApps,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  AppModel app = snapshot.data![index];
                  return FutureBuilder<bool>(
                    future: _cartService.isInCart(app.id),
                    builder: (context, cartSnapshot) {
                      bool isInCart = cartSnapshot.data ?? false;
                      return ListTile(
                        leading: Image.network(
                            'http://localhost:3000/proxy/${Uri.encodeComponent(app.imageUrl)}'),
                        title: Text(app.title),
                        subtitle: Text('${app.description}\n\$${app.price}'),
                        trailing: IconButton(
                          icon: Icon(isInCart
                              ? Icons.shopping_cart
                              : Icons.add_shopping_cart),
                          onPressed: isInCart
                              ? null
                              : () async {
                                  await _cartService.addToCart(app.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '${app.title} added to cart')));
                                  setState(() {});
                                },
                        ),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final List<AppModel> cartItems;

  CheckoutPage({required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final CartService _cartService = CartService();
  String email = '';
  String cardNumber = '';
  String expiration = '';
  String cvv = '';

  Future<bool> _placeOrder(AppModel app) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/checkout/order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'app_id': app.id,
          'card_number': cardNumber,
          'expiration': expiration,
          'cvv': cvv,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Card Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your card number';
                    }
                    return null;
                  },
                  onSaved: (value) => cardNumber = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Expiration'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your card expiration date';
                    }
                    return null;
                  },
                  onSaved: (value) => expiration = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'CVV'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your card CVV';
                    }
                    return null;
                  },
                  onSaved: (value) => cvv = value ?? '',
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      List<bool> orderResults = [];
                      for (var app in widget.cartItems) {
                        orderResults.add(await _placeOrder(app));
                      }

                      if (orderResults.every((result) => result)) {
                        // Clear cart
                        await _cartService.clearCart();
                        // Show success screen
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Success'),
                              content: Text('Your orders have been placed.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.popUntil(
                                        context, ModalRoute.withName('/'));
                                  },
                                  child: Text('Return to Catalog'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(
                                  'There was a problem placing your orders.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text('Pay'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
