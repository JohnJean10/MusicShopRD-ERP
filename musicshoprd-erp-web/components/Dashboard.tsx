import React from 'react';
import { Product } from '../types';
import { AlertTriangle, Package, CheckCircle, TrendingDown } from 'lucide-react';

interface DashboardProps {
  products: Product[];
}

const Dashboard: React.FC<DashboardProps> = ({ products }) => {
  const lowStockProducts = products.filter((p) => p.stock <= p.minStock);
  const totalStock = products.reduce((acc, p) => acc + p.stock, 0);

  return (
    <div className="space-y-6 animate-fade-in">
      <h2 className="text-2xl font-bold text-emerald-400">Dashboard</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-slate-800 p-6 rounded-xl border border-slate-700 shadow-lg flex items-center space-x-4">
          <div className="p-3 bg-orange-500/20 rounded-full">
            <AlertTriangle className="w-8 h-8 text-orange-500" />
          </div>
          <div>
            <p className="text-slate-400 text-sm">Alertas de Stock</p>
            <p className="text-2xl font-bold text-white">
              {lowStockProducts.length} <span className="text-sm font-normal text-slate-400">productos bajos</span>
            </p>
          </div>
        </div>

        <div className="bg-slate-800 p-6 rounded-xl border border-slate-700 shadow-lg flex items-center space-x-4">
          <div className="p-3 bg-blue-500/20 rounded-full">
            <Package className="w-8 h-8 text-blue-500" />
          </div>
          <div>
            <p className="text-slate-400 text-sm">Total Inventario</p>
            <p className="text-2xl font-bold text-white">
              {totalStock} <span className="text-sm font-normal text-slate-400">unidades</span>
            </p>
          </div>
        </div>
      </div>

      <div className="bg-slate-800 rounded-xl border border-slate-700 shadow-lg overflow-hidden">
        <div className="p-4 border-b border-slate-700">
          <h3 className="text-lg font-semibold text-slate-200">Resumen de Stock</h3>
        </div>
        
        {products.length === 0 ? (
          <div className="p-8 text-center text-slate-500">
            <Package className="w-12 h-12 mx-auto mb-2 opacity-50" />
            <p>No hay productos registrados.</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-700">
            {products.map((p) => (
              <div key={p.sku} className="p-4 flex items-center justify-between hover:bg-slate-700/50 transition-colors">
                <div>
                  <p className="font-medium text-white">{p.name}</p>
                  <p className="text-sm text-slate-400">SKU: {p.sku}</p>
                </div>
                <div className="flex items-center space-x-3">
                  <span className="text-sm text-slate-400">Existencia: <strong className="text-white">{p.stock}</strong></span>
                  {p.stock <= p.minStock ? (
                    <TrendingDown className="w-4 h-4 text-red-500" />
                  ) : (
                    <CheckCircle className="w-4 h-4 text-emerald-500" />
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;