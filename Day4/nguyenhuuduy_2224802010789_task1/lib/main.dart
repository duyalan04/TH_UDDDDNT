import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Provider Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyCatalog(),
        '/cart': (context) => const MyCart(),
      },
    );
  }
}

class CartModel extends ChangeNotifier {
  final List<String> _catalog = [
    'Bàn phím cơ',
    'Chuột không dây',
    'Màn hình 4K',
    'Tai nghe Bluetooth',
    'Lót chuột',
  ];

  final List<String> _items = [];

  List<String> get catalog => _catalog;
  List<String> get items => _items;
  int get totalPrice => _items.length * 42;

  void add(String item) {
    _items.add(item);
    notifyListeners();
  }
}

class MyCatalog extends StatelessWidget {
  const MyCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CartModel>().catalog;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: catalog.length,
        itemBuilder: (context, index) {
          final item = catalog[index];
          return _AddButton(item: item);
        },
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String item;
  const _AddButton({required this.item});

  @override
  Widget build(BuildContext context) {
    var isInCart = context.select<CartModel, bool>(
      (cart) => cart.items.contains(item),
    );

    return ListTile(
      title: Text(item, style: const TextStyle(fontSize: 18)),
      trailing: TextButton(
        onPressed: isInCart
            ? null
            : () {
                var cart = context.read<CartModel>();
                cart.add(item);
              },
        child: isInCart
            ? const Icon(Icons.check, semanticLabel: 'ADDED')
            : const Text('THÊM VÀO GIỎ'),
      ),
    );
  }
}

class MyCart extends StatelessWidget {
  const MyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng của bạn')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CartModel>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return const Center(child: Text('Giỏ hàng trống'));
                }
                return ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.done),
                    title: Text(
                      cart.items[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 4, color: Colors.black),
          Container(
            padding: const EdgeInsets.all(24),
            child: Consumer<CartModel>(
              builder: (context, cart, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tổng cộng: ', style: TextStyle(fontSize: 24)),
                  Text(
                    '\$${cart.totalPrice}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
