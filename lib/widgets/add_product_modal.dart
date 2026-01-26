import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _costController;
  late final TextEditingController _weightController;
  late final TextEditingController _minStockController;
  late final TextEditingController _maxStockController;
  late final TextEditingController _priceController;
  late final TextEditingController _brandController;
  
  String? _selectedSupplierId;
  
  // Variantes del producto
  List<_VariantFormData> _variants = [];

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _costController = TextEditingController(text: p?.costUsd.toString() ?? '');
    _weightController = TextEditingController(text: p?.weight.toString() ?? '');
    _minStockController = TextEditingController(text: p?.minStock.toString() ?? '2');
    _maxStockController = TextEditingController(text: p?.maxStock.toString() ?? '10');
    _priceController = TextEditingController(text: p?.price.toString() ?? '0');
    _brandController = TextEditingController(text: p?.brand ?? '');
    
    if (p != null) {
      _selectedSupplierId = p.supplierId;
      // Cargar variantes existentes
      _variants = p.variants.map((v) => _VariantFormData(
        skuController: TextEditingController(text: v.sku),
        colorController: TextEditingController(text: v.color),
        stockController: TextEditingController(text: v.stock.toString()),
      )).toList();
    }
    
    // Si no hay variantes, agregar una por defecto
    if (_variants.isEmpty) {
      _addVariant();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _weightController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  void _addVariant() {
    setState(() {
      _variants.add(_VariantFormData(
        skuController: TextEditingController(),
        colorController: TextEditingController(),
        stockController: TextEditingController(text: '0'),
      ));
    });
  }

  void _removeVariant(int index) {
    if (_variants.length > 1) {
      setState(() {
        _variants[index].dispose();
        _variants.removeAt(index);
      });
    }
  }

  void _generateVariantSku(int index) {
    final notifier = ref.read(productProvider.notifier);
    final brand = _brandController.text;
    final color = _variants[index].colorController.text;
    
    if (brand.length >= 2 && color.isNotEmpty) {
      final sku = notifier.generateVariantSKU(brand, color);
      _variants[index].skuController.text = sku;
    }
  }

  void _handleSave() {
    if (_nameController.text.isEmpty || _brandController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y Marca son requeridos')),
      );
      return;
    }

    // Validar que todas las variantes tengan SKU y color
    for (int i = 0; i < _variants.length; i++) {
      if (_variants[i].skuController.text.isEmpty || _variants[i].colorController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La variante ${i + 1} requiere SKU y Color')),
        );
        return;
      }
    }

    // Generar modelId para nuevo producto
    final notifier = ref.read(productProvider.notifier);
    final isEdit = widget.editProduct != null;
    final modelId = isEdit 
      ? widget.editProduct!.modelId 
      : notifier.generateModelId(_brandController.text);

    // Construir lista de variantes
    final variants = _variants.map((v) => ProductVariant(
      sku: v.skuController.text.trim(),
      color: v.colorController.text.trim(),
      stock: int.tryParse(v.stockController.text) ?? 0,
    )).toList();

    final product = Product(
      modelId: modelId,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      costUsd: double.tryParse(_costController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      minStock: int.tryParse(_minStockController.text) ?? 2,
      maxStock: int.tryParse(_maxStockController.text) ?? 10,
      price: double.tryParse(_priceController.text) ?? 0,
      supplierId: _selectedSupplierId,
      variants: variants,
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
              
              // Datos del Modelo (compartidos por todas las variantes)
              const Text(
                'DATOS DEL MODELO',
                style: TextStyle(color: AppColors.slate400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              
              // Brand & Name
              Row(
                children: [
                  Expanded(
                    child: _buildField('Marca *', _brandController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildField('Nombre del Modelo *', _nameController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Supplier Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSupplierId,
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
              
              // Cost, Weight, Price Row
              Row(
                children: [
                  Expanded(
                    child: _buildField('Costo USD', _costController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Peso (Lbs)', _weightController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Precio RD\$', _priceController, isNumber: true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Min/Max Stock
              Row(
                children: [
                  Expanded(
                    child: _buildField('Stock Mínimo', _minStockController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Stock Máximo', _maxStockController, isNumber: true),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(color: AppColors.slate700),
              const SizedBox(height: 16),
              
              // Variantes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'VARIANTES (Por Color)',
                    style: TextStyle(color: AppColors.slate400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  TextButton.icon(
                    onPressed: _addVariant,
                    icon: const Icon(Icons.add, size: 16, color: AppColors.emerald400),
                    label: const Text('Agregar', style: TextStyle(color: AppColors.emerald400)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Variants List
              ...List.generate(_variants.length, (index) => _buildVariantCard(index)),
              
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

  Widget _buildVariantCard(int index) {
    final variant = _variants[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Color circle indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getColorFromName(variant.colorController.text),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Variante ${index + 1}',
                style: const TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (_variants.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.red400,
                  tooltip: 'Eliminar variante',
                  onPressed: () => _removeVariant(index),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Color
              Expanded(
                flex: 2,
                child: TextField(
                  controller: variant.colorController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) {
                    setState(() {}); // Update color preview
                    _generateVariantSku(index);
                  },
                  decoration: InputDecoration(
                    labelText: 'Color *',
                    hintText: 'Ej: Negro, Dorado',
                    filled: true,
                    fillColor: AppColors.slate800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.slate700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // SKU
              Expanded(
                flex: 2,
                child: TextField(
                  controller: variant.skuController,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: 'SKU *',
                    filled: true,
                    fillColor: AppColors.slate800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.slate700),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.auto_fix_high, size: 16, color: AppColors.emerald400),
                      tooltip: 'Generar SKU',
                      onPressed: () => _generateVariantSku(index),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Stock
              Expanded(
                flex: 1,
                child: TextField(
                  controller: variant.stockController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    filled: true,
                    fillColor: AppColors.slate800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.slate700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final name = colorName.toLowerCase();
    if (name.contains('negro') || name.contains('black')) return Colors.black;
    if (name.contains('blanco') || name.contains('white')) return Colors.white;
    if (name.contains('dorado') || name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('plata') || name.contains('silver')) return Colors.grey.shade400;
    if (name.contains('azul') || name.contains('blue')) return Colors.blue;
    if (name.contains('rojo') || name.contains('red')) return Colors.red;
    if (name.contains('verde') || name.contains('green')) return Colors.green;
    if (name.contains('rosa') || name.contains('pink')) return Colors.pink;
    if (name.contains('morado') || name.contains('purple')) return Colors.purple;
    return AppColors.slate500;
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate700),
        ),
        disabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: AppColors.slate700),
        ),
      ),
    );
  }
}

/// Helper class to manage form data for each variant
class _VariantFormData {
  final TextEditingController skuController;
  final TextEditingController colorController;
  final TextEditingController stockController;
  
  _VariantFormData({
    required this.skuController,
    required this.colorController,
    required this.stockController,
  });
  
  void dispose() {
    skuController.dispose();
    colorController.dispose();
    stockController.dispose();
  }
}
