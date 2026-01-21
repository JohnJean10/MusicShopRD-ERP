import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../providers/app_providers.dart';
import 'app_theme.dart';
import 'add_customer_modal.dart';

class CreateOrderModal extends ConsumerStatefulWidget {
  final List<Product> products;
  final Function(Order) onSave;
  final bool isQuote;

  const CreateOrderModal({
    super.key,
    required this.products,
    required this.onSave,
    this.isQuote = false,
  });

  @override
  ConsumerState<CreateOrderModal> createState() => _CreateOrderModalState();
}

class _CartItem {
  final Product product;
  int quantity = 1;
  
  _CartItem({required this.product});
  
  double get total => product.price * quantity;
}

class _CreateOrderModalState extends ConsumerState<CreateOrderModal> {
  String? _selectedCustomerId;
  final List<_CartItem> _cart = [];
  String _searchTerm = '';

  List<Product> get _filteredProducts {
    if (_searchTerm.isEmpty) return widget.products;
    final term = _searchTerm.toLowerCase();
    return widget.products.where((p) =>
      p.name.toLowerCase().contains(term) ||
      p.sku.toLowerCase().contains(term)
    ).toList();
  }

  double get _cartTotal => _cart.fold(0, (sum, item) => sum + item.total);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$').format(amount);
  }

  void _addToCart(Product product) {
    // Stock Validation
    if (!widget.isQuote && product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay stock disponible para este producto'), backgroundColor: AppColors.red500),
      );
      return;
    }

    final existingIndex = _cart.indexWhere((i) => i.product.sku == product.sku);
    
    if (existingIndex >= 0) {
      // Check if adding 1 more exceeds stock
      if (!widget.isQuote && _cart[existingIndex].quantity + 1 > product.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock insuficiente'), backgroundColor: AppColors.red500),
        );
        return;
      }
      setState(() {
        _cart[existingIndex].quantity++;
      });
    } else {
      setState(() {
        _cart.add(_CartItem(product: product));
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _updateQuantity(int index, int delta) {
    final item = _cart[index];
    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      _removeFromCart(index);
      return;
    }

    // Stock Validation
    if (!widget.isQuote && delta > 0 && newQty > item.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Stock insuficiente para aumentar cantidad'), backgroundColor: AppColors.red500),
      );
      return;
    }

    setState(() {
      item.quantity = newQty;
    });
  }

  void _handleSave() {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un cliente')),
      );
      return;
    }

    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un producto')),
      );
      return;
    }

    // Find customer name
    final customers = ref.read(customerProvider);
    final customer = customers.firstWhere((c) => c.id == _selectedCustomerId, orElse: () => Customer(id: '', name: 'Cliente Desconocido', email: '', phone: '', address: '', taxId: ''));

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: customer.name,
      // In a real app we'd store customerId too, but Order model uses customerName. 
      // We could add customerId to Order model later if needed.
      date: DateTime.now(),
      items: _cart.map((c) => OrderItem(
        sku: c.product.sku,
        name: c.product.name,
        quantity: c.quantity,
        price: c.product.price,
        total: c.total,
      )).toList(),
      total: _cartTotal,
      status: widget.isQuote ? OrderStatus.quote : OrderStatus.pending,
    );

    widget.onSave(order);
    Navigator.of(context).pop();
  }

  void _showAddCustomer() {
    showDialog(
      context: context,
      builder: (context) => AddCustomerModal(
        onSave: (c) {
          ref.read(customerProvider.notifier).addCustomer(c);
          setState(() {
            _selectedCustomerId = c.id;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final customers = ref.watch(customerProvider);

    return Dialog(
      backgroundColor: AppColors.slate800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWide ? 700 : 450,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.slate700)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (widget.isQuote ? AppColors.blue500 : AppColors.emerald500)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.isQuote ? Icons.request_quote : Icons.shopping_cart,
                      color: widget.isQuote ? AppColors.blue400 : AppColors.emerald400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isQuote ? 'Nueva Cotización' : 'Nuevo Pedido',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.slate400),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Selection Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCustomerId,
                            dropdownColor: AppColors.slate800,
                            style: const TextStyle(color: Colors.white),
                            hint: const Text('Seleccionar Cliente', style: TextStyle(color: AppColors.slate400)),
                            decoration: InputDecoration(
                              labelText: 'Cliente',
                              filled: true,
                              fillColor: AppColors.slate900,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.slate700),
                              ),
                            ),
                            items: customers.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedCustomerId = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                         Container(
                           height: 48, // Match input height roughly
                           margin: const EdgeInsets.only(bottom: 2), // Align visually
                           child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.blue500,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                               padding: const EdgeInsets.symmetric(horizontal: 16),
                             ),
                             onPressed: _showAddCustomer,
                             child: const Icon(Icons.person_add, size: 20),
                           ),
                         ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Search
                    const Text(
                      'Agregar Productos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      onChanged: (v) => setState(() => _searchTerm = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar producto...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                        filled: true,
                        fillColor: AppColors.slate900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.slate700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Product Grid
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        color: AppColors.slate900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate700),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final p = _filteredProducts[index];
                          final hasStock = p.stock > 0;
                          return ListTile(
                            dense: true,
                            enabled: widget.isQuote || hasStock,
                            title: Text(p.name, style: TextStyle(color: (widget.isQuote || hasStock) ? Colors.white : AppColors.slate500)),
                            subtitle: Row(
                              children: [
                                Text(
                                  '${p.sku} · ${_formatCurrency(p.price)}',
                                  style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                                ),
                                if (!widget.isQuote && !hasStock)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text('Sin Stock', style: TextStyle(color: AppColors.red500, fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: (widget.isQuote || hasStock) ? AppColors.emerald500 : AppColors.slate600,
                              onPressed: (widget.isQuote || hasStock) ? () => _addToCart(p) : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cart
                    Row(
                      children: [
                        const Text(
                          'Carrito',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald500,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_cart.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (_cart.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.slate900,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate700),
                        ),
                        child: const Center(
                          child: Text(
                            'Carrito vacío',
                            style: TextStyle(color: AppColors.slate500),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.slate900,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate700),
                        ),
                        child: Column(
                          children: [
                            ..._cart.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: idx < _cart.length - 1 
                                    ? const Border(bottom: BorderSide(color: AppColors.slate700)) 
                                    : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            _formatCurrency(item.product.price),
                                            style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                                          color: AppColors.slate400,
                                          onPressed: () => _updateQuantity(idx, -1),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, size: 20),
                                          color: AppColors.emerald400,
                                          onPressed: () => _updateQuantity(idx, 1),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        _formatCurrency(item.total),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: AppColors.emerald400,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      color: AppColors.red400,
                                      onPressed: () => _removeFromCart(idx),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.slate900,
                border: Border(top: BorderSide(color: AppColors.slate700)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(color: AppColors.slate400, fontSize: 12),
                      ),
                      Text(
                        _formatCurrency(_cartTotal),
                        style: const TextStyle(
                          color: AppColors.emerald400,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: (_selectedCustomerId != null && _cart.isNotEmpty) ? _handleSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isQuote ? AppColors.blue500 : AppColors.emerald600,
                      disabledBackgroundColor: AppColors.slate700,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: Icon(widget.isQuote ? Icons.request_quote : Icons.check),
                    label: Text(widget.isQuote ? 'Crear Cotización' : 'Confirmar Pedido'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
