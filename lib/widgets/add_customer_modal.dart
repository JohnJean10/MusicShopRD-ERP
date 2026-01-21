import 'package:flutter/material.dart';
import '../models/customer.dart';
import 'app_theme.dart';

class AddCustomerModal extends StatefulWidget {
  final Customer? customer;
  final Function(Customer) onSave;

  const AddCustomerModal({super.key, this.customer, required this.onSave});

  @override
  State<AddCustomerModal> createState() => _AddCustomerModalState();
}

class _AddCustomerModalState extends State<AddCustomerModal> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _taxCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _taxCtrl = TextEditingController(text: c?.taxId ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.isEmpty) return;

    final newCustomer = Customer(
      id: widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      taxId: _taxCtrl.text.trim(),
    );

    widget.onSave(newCustomer);
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
                widget.customer == null ? 'Nuevo Cliente' : 'Editar Cliente',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildField('Nombre *', _nameCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField('Teléfono', _phoneCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('RNC/Cédula', _taxCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              _buildField('Email', _emailCtrl),
              const SizedBox(height: 12),
              _buildField('Dirección', _addressCtrl),
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
