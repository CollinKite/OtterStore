import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const _cartKey = 'cart';

  Future<List<String>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cartKey) ?? [];
  }

  Future<void> addToCart(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList(_cartKey) ?? [];
    if (!cart.contains(appId)) {
      cart.add(appId);
      await prefs.setStringList(_cartKey, cart);
    }
  }

  Future<void> removeFromCart(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList(_cartKey) ?? [];
    cart.remove(appId);
    await prefs.setStringList(_cartKey, cart);
  }

  Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cart', []);
  }

  Future<bool> isInCart(String appId) async {
    List<String> cart = await getCart();
    return cart.contains(appId);
  }
}
