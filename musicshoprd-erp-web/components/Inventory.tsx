import React, { useState } from 'react';
import { Product, AppConfigState } from '../types';
import { Trash2, FileSpreadsheet, Printer, Plus, Search, AlertTriangle, ArrowDownToLine, ArrowUpToLine } from 'lucide-react';

interface InventoryProps {
  products: Product[];
  config: AppConfigState;
  onDelete: (sku: string) => void;
  onAdd: () => void;
}

const Inventory: React.FC<InventoryProps> = ({ products, config, onDelete, onAdd }) => {
  const [searchTerm, setSearchTerm] = useState('');

  const calculateLandedCost = (usd: number, weight: number): number => {
    return (usd * config.exchangeRate) + (weight * config.courierRate) + config.packaging;
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-DO', { style: 'currency', currency: 'DOP' }).format(amount);
  };

  const filteredProducts = products.filter(p => 
    p.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    p.sku.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const exportToCSV = () => {
    const headers = ['SKU,Nombre,Precio Venta,Costo USD,Stock,Min,Max'];
    const rows = products.map(p => {
      return `${p.sku},"${p.name}",${p.price || 0},${p.costUsd},${p.stock},${p.minStock},${p.maxStock}`;
    });
    const csvContent = "data:text/csv;charset=utf-8," + [headers, ...rows].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "inventario_musicshop.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="space-y-4 h-full flex flex-col">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h2 className="text-2xl font-bold text-emerald-400">Inventario</h2>
        <div className="flex gap-2 w-full sm:w-auto">
          <button onClick={handlePrint} className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-slate-700 hover:bg-slate-600 text-white px-3 py-2 rounded-lg transition-colors">
            <Printer size={18} />
            <span className="hidden sm:inline">Imprimir</span>
          </button>
          <button onClick={exportToCSV} className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-3 py-2 rounded-lg transition-colors">
            <FileSpreadsheet size={18} />
            <span className="hidden sm:inline">Excel/CSV</span>
          </button>
          <button onClick={onAdd} className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-3 py-2 rounded-lg transition-colors shadow-lg shadow-blue-900/50">
            <Plus size={18} />
            <span>Nuevo</span>
          </button>
        </div>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
        <input 
          type="text" 
          placeholder="Buscar por nombre o SKU..." 
          className="w-full bg-slate-800 border border-slate-700 text-white rounded-lg pl-10 pr-4 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      <div className="flex-1 overflow-auto bg-slate-800 rounded-xl border border-slate-700 shadow-lg">
        <table className="w-full text-left border-collapse">
          <thead className="bg-slate-900/50 sticky top-0 z-10">
            <tr>
              <th className="p-4 text-slate-400 font-semibold text-sm">Producto</th>
              <th className="p-4 text-slate-400 font-semibold text-sm text-center">Niveles (Min/Max)</th>
              <th className="p-4 text-slate-400 font-semibold text-sm text-center">Estado Stock</th>
              <th className="p-4 text-slate-400 font-semibold text-sm text-right">Precio Venta</th>
              <th className="p-4 text-slate-400 font-semibold text-sm text-right hidden md:table-cell">Landed Cost</th>
              <th className="p-4 text-slate-400 font-semibold text-sm text-center">Acciones</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-700">
            {filteredProducts.map((p) => {
              const landed = calculateLandedCost(p.costUsd, p.weight);
              const isLow = p.stock <= p.minStock;
              const isOver = p.stock > p.maxStock;
              
              // Calculate percentage for bar (clamped 0-100)
              const maxScale = Math.max(p.maxStock * 1.2, p.stock, 10);
              const percent = Math.min((p.stock / maxScale) * 100, 100);

              return (
                <tr key={p.sku} className="hover:bg-slate-700/30 transition-colors">
                  <td className="p-4">
                    <div className="font-medium text-white">{p.name}</div>
                    <div className="text-xs text-slate-500">{p.sku}</div>
                  </td>
                  <td className="p-4 text-center">
                    <div className="flex items-center justify-center gap-2 text-xs font-mono text-slate-400">
                        <span className="flex items-center text-orange-400/80"><ArrowDownToLine size={12} className="mr-0.5"/>{p.minStock}</span>
                        <span className="text-slate-600">|</span>
                        <span className="flex items-center text-blue-400/80"><ArrowUpToLine size={12} className="mr-0.5"/>{p.maxStock}</span>
                    </div>
                  </td>
                  <td className="p-4">
                     <div className="flex flex-col gap-1">
                        <div className="flex justify-between items-end">
                            <span className={`font-bold text-lg ${isLow ? 'text-red-400' : isOver ? 'text-blue-300' : 'text-emerald-400'}`}>
                                {p.stock}
                            </span>
                             {isLow && <span className="text-xs text-red-400 font-medium flex items-center"><AlertTriangle size={10} className="mr-1"/>Bajo</span>}
                             {isOver && <span className="text-xs text-blue-300 font-medium">Exceso</span>}
                        </div>
                        {/* Visual Bar */}
                        <div className="h-1.5 w-full bg-slate-900 rounded-full overflow-hidden">
                            <div 
                                className={`h-full rounded-full ${isLow ? 'bg-red-500' : isOver ? 'bg-blue-500' : 'bg-emerald-500'}`} 
                                style={{ width: `${percent}%` }}
                            ></div>
                        </div>
                     </div>
                  </td>
                  <td className="p-4 text-right text-white font-medium">
                    {formatCurrency(p.price || 0)}
                  </td>
                  <td className="p-4 text-right hidden md:table-cell font-mono text-slate-400 text-sm">
                    {formatCurrency(landed)}
                  </td>
                  <td className="p-4 text-center">
                    <button 
                      onClick={() => onDelete(p.sku)}
                      className="text-slate-400 hover:text-red-400 hover:bg-red-500/10 p-2 rounded-full transition-colors"
                      title="Eliminar"
                    >
                      <Trash2 size={18} />
                    </button>
                  </td>
                </tr>
              );
            })}
            {filteredProducts.length === 0 && (
              <tr>
                <td colSpan={6} className="p-8 text-center text-slate-500">
                  No se encontraron productos.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Inventory;