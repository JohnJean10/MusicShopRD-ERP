import React, { useState, useEffect } from 'react';
import { Product } from '../types';
import { X, AlertTriangle, Wand2 } from 'lucide-react';
import { generateSKU } from '../utils/skuGenerator';

interface AddProductModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (product: Product) => void;
  products: Product[];
}

const AddProductModal: React.FC<AddProductModalProps> = ({ isOpen, onClose, onSave, products }) => {
  const [formData, setFormData] = useState<Partial<Product>>({
    sku: '',
    name: '',
    brand: '',
    color: '',
    costUsd: 0,
    weight: 0,
    stock: 0,
    minStock: 2,
    maxStock: 20,
    price: 0,
  });

  // Auto-generate SKU when brand or color changes if SKU is empty or looks auto-generated
  const handleAutoSKU = () => {
    if (formData.brand && formData.brand.length >= 2) {
      const newSKU = generateSKU(formData.brand, formData.color, products);
      setFormData(prev => ({ ...prev, sku: newSKU }));
    }
  };

  if (!isOpen) return null;

  const handleChange = (key: keyof Product, value: string) => {
    const numKeys = ['costUsd', 'weight', 'stock', 'minStock', 'maxStock', 'price'];
    setFormData(prev => ({
      ...prev,
      [key]: numKeys.includes(key) ? (parseFloat(value) || 0) : value
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (formData.sku && formData.name) {
      onSave(formData as Product);
      setFormData({
        sku: '',
        name: '',
        brand: '',
        color: '',
        costUsd: 0,
        weight: 0,
        stock: 0,
        minStock: 2,
        maxStock: 20,
        price: 0,
      });
      onClose();
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
      <div className="bg-slate-800 rounded-xl border border-slate-700 w-full max-w-lg shadow-2xl animate-fade-in-up">
        <div className="flex justify-between items-center p-6 border-b border-slate-700">
          <h3 className="text-xl font-bold text-white">Nuevo Producto</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white transition-colors">
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1">
              <label className="text-sm font-medium text-slate-300">Marca *</label>
              <input required type="text" placeholder="Ej: Redmond" className="w-full bg-slate-900 border border-slate-600 rounded-lg p-2.5 text-white focus:ring-1 focus:ring-emerald-500 outline-none"
                value={formData.brand || ''} onChange={e => handleChange('brand', e.target.value)} />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-medium text-slate-300">Color (Opcional)</label>
              <input type="text" placeholder="Ej: Black" className="w-full bg-slate-900 border border-slate-600 rounded-lg p-2.5 text-white focus:ring-1 focus:ring-emerald-500 outline-none"
                value={formData.color || ''} onChange={e => handleChange('color', e.target.value)} />
            </div>
          </div>

          <div className="flex gap-2 items-end">
            <div className="space-y-1 flex-1">
              <label className="text-sm font-medium text-slate-300">SKU</label>
              <input required type="text" className="w-full bg-slate-900 border border-slate-600 rounded-lg p-2.5 text-white focus:ring-1 focus:ring-emerald-500 outline-none font-mono tracking-wider"
                value={formData.sku} onChange={e => handleChange('sku', e.target.value)} />
            </div>
            <button
              type="button"
              onClick={handleAutoSKU}
              disabled={!formData.brand || formData.brand.length < 2}
              className="bg-purple-600 hover:bg-purple-700 disabled:opacity-50 disabled:cursor-not-allowed text-white px-4 py-2.5 rounded-lg flex items-center gap-2 transition-colors"
              title="Generar SKU Automático"
            >
              <Wand2 size={18} />
              <span className="text-sm font-medium">Auto</span>
            </button>
          </div>

          <div className="space-y-1">
            <label className="text-sm font-medium text-slate-300">Nombre del Producto</label>
            <input required type="text" className="w-full bg-slate-900 border border-slate-600 rounded-lg p-2.5 text-white focus:ring-1 focus:ring-emerald-500 outline-none"
              value={formData.name} onChange={e => handleChange('name', e.target.value)} />
          </div>

          <div className="p-4 bg-slate-900/50 rounded-lg border border-slate-700 space-y-3">
            <h4 className="text-sm font-bold text-emerald-400 flex items-center gap-2">
              <AlertTriangle size={14} /> Control de Inventario
            </h4>
            <div className="grid grid-cols-3 gap-3">
              <div className="space-y-1">
                <label className="text-xs font-medium text-slate-400">Stock Actual</label>
                <input required type="number" className="w-full bg-slate-800 border border-slate-600 rounded p-2 text-white text-center font-bold focus:ring-1 focus:ring-emerald-500 outline-none"
                  value={formData.stock} onChange={e => handleChange('stock', e.target.value)} />
              </div>
              <div className="space-y-1">
                <label className="text-xs font-medium text-slate-400">Mínimo</label>
                <input required type="number" className="w-full bg-slate-800 border border-slate-600 rounded p-2 text-white text-center focus:ring-1 focus:ring-orange-500 outline-none"
                  value={formData.minStock} onChange={e => handleChange('minStock', e.target.value)} />
              </div>
              <div className="space-y-1">
                <label className="text-xs font-medium text-slate-400">Máximo</label>
                <input required type="number" className="w-full bg-slate-800 border border-slate-600 rounded p-2 text-white text-center focus:ring-1 focus:ring-blue-500 outline-none"
                  value={formData.maxStock} onChange={e => handleChange('maxStock', e.target.value)} />
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1">
              <label className="text-sm font-medium text-slate-300">Precio Venta (RD$)</label>
              <input required type="number" step="1" className="w-full bg-slate-900 border border-slate-600 rounded-lg p-2.5 text-white focus:ring-1 focus:ring-emerald-500 outline-none"
                value={formData.price} onChange={e => handleChange('price', e.target.value)} />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-medium text-slate-300">Peso (Lb)</label>
              <input required type="number" step="0.01" className="w-full bg-slate-900 border border-slate-600 rounded-lg p-2.5 text-white focus:ring-1 focus:ring-emerald-500 outline-none"
                value={formData.weight} onChange={e => handleChange('weight', e.target.value)} />
            </div>
          </div>

          <div className="space-y-1">
            <label className="text-sm font-medium text-slate-300">Costo Base (USD)</label>
            <input required type="number" step="0.01" className="w-full bg-slate-900 border border-slate-600 rounded-lg p-2.5 text-white focus:ring-1 focus:ring-emerald-500 outline-none"
              value={formData.costUsd} onChange={e => handleChange('costUsd', e.target.value)} />
          </div>

          <div className="pt-4 flex justify-end gap-3">
            <button type="button" onClick={onClose} className="px-4 py-2 rounded-lg text-slate-300 hover:bg-slate-700 transition-colors">
              Cancelar
            </button>
            <button type="submit" className="px-6 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-medium transition-colors shadow-lg shadow-emerald-900/30">
              Guardar Producto
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AddProductModal;