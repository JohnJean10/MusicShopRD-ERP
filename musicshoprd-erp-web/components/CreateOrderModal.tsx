import React, { useState } from 'react';
import { Order, OrderItem, Product } from '../types';
import { X, Plus, Trash2, ShoppingCart, FileText } from 'lucide-react';

interface CreateOrderModalProps {
  isOpen: boolean;
  onClose: () => void;
  products: Product[];
  onSave: (order: Order) => void;
}

const CreateOrderModal: React.FC<CreateOrderModalProps> = ({ isOpen, onClose, products, onSave }) => {
  const [customer, setCustomer] = useState('');
  const [items, setItems] = useState<OrderItem[]>([]);
  const [selectedSku, setSelectedSku] = useState('');

  // Reset state when closing
  const handleClose = () => {
    setCustomer('');
    setItems([]);
    setSelectedSku('');
    onClose();
  };

  const addItem = () => {
    if (!selectedSku) return;
    const product = products.find(p => p.sku === selectedSku);
    if (!product) return;

    // Check if already in list
    const existing = items.find(i => i.sku === selectedSku);
    if (existing) {
      updateQuantity(existing.sku, existing.quantity + 1);
    } else {
      setItems([...items, {
        sku: product.sku,
        name: product.name,
        quantity: 1,
        price: product.price || 0,
        total: (product.price || 0)
      }]);
    }
    setSelectedSku('');
  };

  const updateQuantity = (sku: string, newQty: number) => {
    if (newQty < 1) return;
    const product = products.find(p => p.sku === sku);
    if (!product) return;
    
    // Warn about stock but allow adding (for quotes)
    if (newQty > product.stock) {
        // Optional: Add visual warning here
    }

    setItems(items.map(item => 
      item.sku === sku 
        ? { ...item, quantity: newQty, total: newQty * item.price }
        : item
    ));
  };

  const updatePrice = (sku: string, newPrice: number) => {
    setItems(items.map(item => 
      item.sku === sku 
        ? { ...item, price: newPrice, total: item.quantity * newPrice }
        : item
    ));
  };

  const removeItem = (sku: string) => {
    setItems(items.filter(i => i.sku !== sku));
  };

  const grandTotal = items.reduce((acc, item) => acc + item.total, 0);

  const handleSubmit = (status: Order['status']) => {
    if (!customer || items.length === 0) return;

    const newOrder: Order = {
      id: crypto.randomUUID(),
      customerName: customer,
      date: new Date().toISOString(),
      items: items,
      total: grandTotal,
      status: status
    };

    onSave(newOrder);
    handleClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
      <div className="bg-slate-800 rounded-xl border border-slate-700 w-full max-w-4xl shadow-2xl animate-fade-in-up flex flex-col max-h-[90vh]">
        
        {/* Header */}
        <div className="flex justify-between items-center p-6 border-b border-slate-700">
          <div className="flex items-center gap-3">
            <div className="bg-emerald-500/20 p-2 rounded-lg">
                <ShoppingCart className="text-emerald-500 w-6 h-6" />
            </div>
            <h3 className="text-xl font-bold text-white">Nuevo Pedido / Cotización</h3>
          </div>
          <button onClick={handleClose} className="text-slate-400 hover:text-white transition-colors">
            <X size={24} />
          </button>
        </div>
        
        <div className="flex-1 overflow-auto p-6 space-y-6">
            {/* Customer Info */}
            <div className="space-y-2">
                <label className="text-sm font-medium text-slate-300">Nombre del Cliente</label>
                <input 
                    type="text" 
                    placeholder="Ej. Juan Pérez"
                    className="w-full bg-slate-900 border border-slate-600 rounded-lg p-3 text-white focus:ring-1 focus:ring-emerald-500 outline-none" 
                    value={customer} 
                    onChange={e => setCustomer(e.target.value)} 
                />
            </div>

            {/* Add Item Bar */}
            <div className="flex gap-2 items-end">
                <div className="flex-1 space-y-2">
                    <label className="text-sm font-medium text-slate-300">Agregar Producto</label>
                    <select 
                        className="w-full bg-slate-900 border border-slate-600 rounded-lg p-3 text-white focus:ring-1 focus:ring-emerald-500 outline-none appearance-none"
                        value={selectedSku}
                        onChange={(e) => setSelectedSku(e.target.value)}
                    >
                        <option value="">Seleccionar producto...</option>
                        {products.map(p => (
                            <option key={p.sku} value={p.sku}>
                                {p.name} (Stock: {p.stock}) - RD${p.price || 0}
                            </option>
                        ))}
                    </select>
                </div>
                <button 
                    onClick={addItem}
                    disabled={!selectedSku}
                    className="bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed text-white px-4 py-3 rounded-lg font-medium transition-colors"
                >
                    <Plus size={20} />
                </button>
            </div>

            {/* Items Table */}
            <div className="bg-slate-900/50 rounded-lg border border-slate-700 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-slate-900 text-slate-400 text-xs uppercase font-semibold">
                        <tr>
                            <th className="p-3">Producto</th>
                            <th className="p-3 text-center">Cant.</th>
                            <th className="p-3 text-right">Precio (RD$)</th>
                            <th className="p-3 text-right">Total</th>
                            <th className="p-3 text-center"></th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800">
                        {items.map((item) => (
                            <tr key={item.sku}>
                                <td className="p-3 font-medium text-white">{item.name}</td>
                                <td className="p-3 text-center">
                                    <input 
                                        type="number" 
                                        min="1"
                                        className="w-16 bg-slate-800 border border-slate-700 rounded p-1 text-center text-white"
                                        value={item.quantity}
                                        onChange={(e) => updateQuantity(item.sku, parseInt(e.target.value) || 1)}
                                    />
                                </td>
                                <td className="p-3 text-right">
                                     <input 
                                        type="number" 
                                        className="w-24 bg-slate-800 border border-slate-700 rounded p-1 text-right text-white"
                                        value={item.price}
                                        onChange={(e) => updatePrice(item.sku, parseFloat(e.target.value) || 0)}
                                    />
                                </td>
                                <td className="p-3 text-right font-bold text-emerald-400">
                                    RD${item.total.toLocaleString()}
                                </td>
                                <td className="p-3 text-center">
                                    <button onClick={() => removeItem(item.sku)} className="text-red-400 hover:bg-red-500/10 p-1.5 rounded transition-colors">
                                        <Trash2 size={16} />
                                    </button>
                                </td>
                            </tr>
                        ))}
                        {items.length === 0 && (
                            <tr>
                                <td colSpan={5} className="p-8 text-center text-slate-500 italic">
                                    Agrega productos para cotizar o vender...
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>

        {/* Footer */}
        <div className="p-6 border-t border-slate-700 bg-slate-800/50 flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="text-right md:text-left w-full md:w-auto">
                <p className="text-sm text-slate-400">Total a Pagar</p>
                <p className="text-3xl font-bold text-emerald-400">RD${grandTotal.toLocaleString()}</p>
            </div>
            <div className="flex gap-3 w-full md:w-auto">
                <button 
                    onClick={() => handleSubmit('quote')}
                    disabled={items.length === 0 || !customer}
                    className="flex-1 md:flex-none px-4 py-3 border border-slate-600 hover:bg-slate-700 text-slate-200 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
                >
                    <FileText size={18} />
                    Guardar Cotización
                </button>
                <button 
                    onClick={() => handleSubmit('pending')}
                    disabled={items.length === 0 || !customer}
                    className="flex-1 md:flex-none px-6 py-3 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-50 disabled:cursor-not-allowed text-white rounded-lg font-bold transition-colors shadow-lg shadow-emerald-900/30 flex items-center justify-center gap-2"
                >
                    <ShoppingCart size={18} />
                    Confirmar Venta
                </button>
            </div>
        </div>
      </div>
    </div>
  );
};

export default CreateOrderModal;