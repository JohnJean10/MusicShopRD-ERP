import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models/product.dart';
import '../providers/app_providers.dart';
import 'app_theme.dart';

class AddProductModal extends ConsumerStatefulWidget {
  final Function(Product) onSave;
  final Product? editProduct;

  const AddProductModal({
    super.key,
    required this.onSave,
    this.editProduct,
  });

  @override
  ConsumerState<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends ConsumerState<AddProductModal> {
  late final TextEditingController _skuController;
  late final TextEditingController _nameController;
  late final TextEditingController _costController;
  late final TextEditingController _weightController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _maxStockController;
  late final TextEditingController _priceController;
  late final TextEditingController _brandController;
  late final TextEditingController _colorController;
  
  bool _autoSku = false;
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;
    _skuController = TextEditingController(text: p?.sku ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _costController = TextEditingController(text: p?.costUsd.toString() ?? '');
    _weightController = TextEditingController(text: p?.weight.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _minStockController = TextEditingController(text: p?.minStock.toString() ?? '2');
    _maxStockController = TextEditingController(text: p?.maxStock.toString() ?? '10');
    _priceController = TextEditingController(text: p?.price.toString() ?? '0');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _colorController = TextEditingController(text: p?.color ?? '');
    
    if (p != null) {
      _selectedSupplierId = p.supplierId;
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _costController.dispose();
    _weightController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _generateSku() {
    if (_autoSku) {
       final notifier = ref.read(productProvider.notifier);
       final sku = notifier.generateAutoSKU(
         _brandController.text, 
         _colorController.text
       );
       if (sku.isNotEmpty) {
         _skuController.text = sku;
       }
    } else if (widget.editProduct == null) {
       _skuController.clear();
    }
  }

  void _handleSave() {
    if ((!_autoSku && _skuController.text.isEmpty) || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SKU y Nombre son requeridos')),
      );
      return;
    }

    final product = Product(
      sku: _skuController.text.trim(),
      name: _nameController.text.trim(),
      costUsd: double.tryParse(_costController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      minStock: int.tryParse(_minStockController.text) ?? 2,
      maxStock: int.tryParse(_maxStockController.text) ?? 10,
      price: double.tryParse(_priceController.text) ?? 0,
      supplierId: _selectedSupplierId,
      brand: _brandController.text.trim(),
      color: _colorController.text.trim(),
    );

    widget.onSave(product);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editProduct != null;
    final suppliers = ref.watch(supplierProvider);
    
    return Dialog(
      backgroundColor: AppColors.slate800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emerald500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2, color: AppColors.emerald400),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Editar Producto' : 'Nuevo Producto',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
               // Brand & Color (for SKU)
               Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'Marca *', 
                      _brandController,
                      onChanged: (_) {
                        if (_autoSku) _generateSku();
                      }
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      'Color', 
                      _colorController,
                      onChanged: (_) {
                        if (_autoSku) _generateSku();
                      }
                    ),
                  ),
                ],
               ),
               const SizedBox(height: 16),

              // SKU & Auto-Gen
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildField(
                      'SKU', 
                      _skuController, 
                      enabled: !isEdit && !_autoSku
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isEdit)
                    Column(
                      children: [
                         const Text('Auto SKU', style: TextStyle(color: AppColors.slate400, fontSize: 10)),
                        Switch(
                          value: _autoSku,
                          activeThumbColor: AppColors.emerald500,
                          onChanged: (val) {
                            setState(() {
                              _autoSku = val;
                              _generateSku();
                            });
                          },
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              _buildField('Nombre', _nameController),
              const SizedBox(height: 16),
              
              // Supplier Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSupplierId,
                dropdownColor: AppColors.slate800,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Proveedor',
                  filled: true,
                  fillColor: AppColors.slate900,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate700),
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sin proveedor')),
                  ...suppliers.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedSupplierId = val),
              ),
              const SizedBox(height: 16),
              
              // Cost & Weight Row
              Row(
                children: [
                  Expanded(
                    child: _buildField('Costo USD', _costController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Peso (Lbs)', _weightController, isNumber: true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Price
              _buildField('Precio Venta (RD\$)', _priceController, isNumber: true),
              const SizedBox(height: 16),
              
              // Stock Row
              Row(
                children: [
                  Expanded(
                    child: _buildField('Stock', _stockController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Mín', _minStockController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Máx', _maxStockController, isNumber: true),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      style: TextStyle(color: enabled ? Colors.white : AppColors.slate500),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? AppColors.slate900 : AppColors.slate800,
        disabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: AppColors.slate700),
        ),
      ),
    );
  }
}
