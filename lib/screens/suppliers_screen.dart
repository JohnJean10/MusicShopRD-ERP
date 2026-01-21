import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier.dart';
import '../providers/app_providers.dart';
import '../widgets/app_theme.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _searchTerm = '';

  void _showAddEditModal([Supplier? supplier]) {
    showDialog(
      context: context,
      builder: (context) => _AddEditSupplierModal(
        supplier: supplier,
        onSave: (s) {
          if (supplier == null) {
            ref.read(supplierProvider.notifier).addSupplier(s);
          } else {
            ref.read(supplierProvider.notifier).updateSupplier(s);
          }
        },
      ),
    );
  }

  void _confirmDelete(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text('¿Estás seguro de eliminar a "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () {
              ref.read(supplierProvider.notifier).deleteSupplier(supplier.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierProvider);
    final filtered = _searchTerm.isEmpty
        ? suppliers
        : suppliers.where((s) =>
            s.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            s.contactName.toLowerCase().contains(_searchTerm.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Proveedores',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald400,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue500),
                    onPressed: () => _showAddEditModal(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo Proveedor'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _searchTerm = v),
                decoration: InputDecoration(
                  hintText: 'Buscar proveedor...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                  filled: true,
                  fillColor: AppColors.slate800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate700),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    suppliers.isEmpty ? 'No hay proveedores registrados.' : 'No se encontraron resultados.',
                    style: const TextStyle(color: AppColors.slate500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    return Card(
                      color: AppColors.slate800,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.blue500.withValues(alpha: 0.2),
                          child: const Icon(Icons.business, color: AppColors.blue400, size: 20),
                        ),
                        title: Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.contactName.isEmpty ? 'Sin contacto' : s.contactName, style: const TextStyle(color: AppColors.slate400, fontSize: 13)),
                            if (s.phone.isNotEmpty) Text(s.phone, style: const TextStyle(color: AppColors.slate400, fontSize: 13)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: AppColors.blue400),
                              onPressed: () => _showAddEditModal(s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: AppColors.slate500),
                              onPressed: () => _confirmDelete(s),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AddEditSupplierModal extends StatefulWidget {
  final Supplier? supplier;
  final Function(Supplier) onSave;

  const _AddEditSupplierModal({this.supplier, required this.onSave});

  @override
  State<_AddEditSupplierModal> createState() => _AddEditSupplierModalState();
}

class _AddEditSupplierModalState extends State<_AddEditSupplierModal> {
  late TextEditingController _nameCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _categoryCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _contactCtrl = TextEditingController(text: s?.contactName ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _categoryCtrl = TextEditingController(text: s?.category ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.isEmpty) return;

    final newSupplier = Supplier(
      id: widget.supplier?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      contactName: _contactCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
    );

    widget.onSave(newSupplier);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.slate900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildField('Empresa *', _nameCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField('Contacto', _contactCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Teléfono', _phoneCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              _buildField('Email', _emailCtrl),
              const SizedBox(height: 12),
              _buildField('Categoría / Productos', _categoryCtrl),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald500),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.slate800,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
