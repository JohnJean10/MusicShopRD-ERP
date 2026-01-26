import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/purchase_order.dart';
import '../models/supplier.dart';
import '../providers/app_providers.dart';
import 'app_theme.dart';

class CreatePurchaseOrderModal extends ConsumerStatefulWidget {
  const CreatePurchaseOrderModal({super.key});

  @override
  ConsumerState<CreatePurchaseOrderModal> createState() => _CreatePurchaseOrderModalState();
}

class _CreatePurchaseOrderModalState extends ConsumerState<CreatePurchaseOrderModal> {
  final _formKey = GlobalKey<FormState>();
  
  Supplier? _selectedSupplier;
  final List<PurchaseOrderItem> _items = [];
  
  // Item form fields
  Product? _selectedProduct;
  String? _selectedVariantSku;
  final _qtyController = TextEditingController(text: '1');
  final _costController = TextEditingController();

  void _addItem() {
    if (_selectedProduct == null || _costController.text.isEmpty) return;
    
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final cost = double.tryParse(_costController.text) ?? 0.0;
    
    // Determine details based on variant or base product
    String sku = _selectedProduct!.primarySku;
    String name = _selectedProduct!.name;
    
    if (_selectedVariantSku != null) {
      final variant = _selectedProduct!.variants.firstWhere(
        (v) => v.sku == _selectedVariantSku,
        orElse: () => _selectedProduct!.variants.first
      );
      sku = variant.sku;
      name = '${_selectedProduct!.name} (${variant.color})';
    }

    setState(() {
      _items.add(PurchaseOrderItem(
        sku: sku,
        name: name,
        quantity: qty,
        costUsd: cost,
        total: cost * qty,
      ));
      
      // Reset item fields
      _selectedProduct = null;
      _selectedVariantSku = null;
      _qtyController.text = '1';
      _costController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveOrder() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSupplier == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un proveedor')),
        );
        return;
      }
      
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agregue al menos un producto')),
        );
        return;
      }

      final totalUsd = _items.fold(0.0, (sum, item) => sum + item.total);

      final newOrder = PurchaseOrder(
        id: const Uuid().v4(),
        supplierId: _selectedSupplier!.id,
        supplierName: _selectedSupplier!.name,
        date: DateTime.now(),
        items: _items,
        totalUsd: totalUsd,
        status: PurchaseOrderStatus.pending,
      );

      ref.read(purchaseOrderProvider.notifier).addPurchaseOrder(newOrder);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierProvider);
    final products = ref.watch(productProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva Orden de Compra',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.slate400),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Supplier Selection
            DropdownButtonFormField<Supplier>(
              value: _selectedSupplier,
              dropdownColor: AppColors.slate800,
              decoration: const InputDecoration(labelText: 'Proveedor'),
              items: suppliers.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.name, style: const TextStyle(color: Colors.white)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedSupplier = val),
            ),
            const SizedBox(height: 24),

            const Divider(color: AppColors.slate700),
            const SizedBox(height: 16),
            const Text('Items', style: TextStyle(color: AppColors.slate300, fontSize: 16)),
            const SizedBox(height: 16),

            // Add Item Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      DropdownButtonFormField<Product>(
                        value: _selectedProduct,
                        isExpanded: true,
                        dropdownColor: AppColors.slate800,
                        decoration: const InputDecoration(labelText: 'Producto'),
                        items: products.map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedProduct = val;
                            _selectedVariantSku = null;
                            if (val != null) {
                               // Default cost from product costUsd
                               _costController.text = val.costUsd.toString();
                            }
                          });
                        },
                      ),
                      if (_selectedProduct != null && _selectedProduct!.variants.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: DropdownButtonFormField<String>(
                            value: _selectedVariantSku,
                            dropdownColor: AppColors.slate800,
                            decoration: const InputDecoration(labelText: 'Variante'),
                            items: _selectedProduct!.variants.map((v) => DropdownMenuItem(
                              value: v.sku,
                              child: Text('${v.color} (Stock: ${v.stock})', style: const TextStyle(color: Colors.white)),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedVariantSku = val),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Cant.'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Costo \$'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle, color: AppColors.emerald500, size: 32),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Items List
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.slate700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _items.isEmpty
                ? const Center(child: Text('Sin items', style: TextStyle(color: AppColors.slate500)))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Qty: ${item.quantity} | Cost: \$${item.costUsd}', style: const TextStyle(color: AppColors.slate400)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.red400),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),

            const SizedBox(height: 24),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'Total: US\$${_items.fold(0.0, (sum, item) => sum + item.total).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Crear Orden'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
