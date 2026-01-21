import React, { useState } from 'react';
import { AppConfigState } from '../types';
import { Calculator as CalcIcon, RefreshCw } from 'lucide-react';

interface CalculatorProps {
  config: AppConfigState;
}

const Calculator: React.FC<CalculatorProps> = ({ config }) => {
  const [usd, setUsd] = useState<string>('');
  const [weight, setWeight] = useState<string>('');

  const usdVal = parseFloat(usd) || 0;
  const weightVal = parseFloat(weight) || 0;

  const landedCost = (usdVal * config.exchangeRate) + (weightVal * config.courierRate) + config.packaging;

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-DO', { style: 'currency', currency: 'DOP' }).format(amount);
  };

  return (
    <div className="max-w-2xl mx-auto space-y-8 animate-fade-in pt-8">
      <div className="text-center space-y-2">
        <div className="inline-flex items-center justify-center p-4 bg-emerald-500/10 rounded-full mb-4">
          <CalcIcon className="w-12 h-12 text-emerald-500" />
        </div>
        <h2 className="text-3xl font-bold text-white">Calculadora de Costos</h2>
        <p className="text-slate-400">Calcula el costo puesto en RD (Landed Cost)</p>
      </div>

      <div className="bg-slate-800 p-8 rounded-2xl border border-slate-700 shadow-xl space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-400">Costo Producto (USD)</label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500">$</span>
              <input
                type="number"
                value={usd}
                onChange={(e) => setUsd(e.target.value)}
                className="w-full bg-slate-900 border border-slate-600 rounded-lg py-3 pl-8 pr-4 text-white focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition-all"
                placeholder="0.00"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-400">Peso (Libras)</label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500">Lb</span>
              <input
                type="number"
                value={weight}
                onChange={(e) => setWeight(e.target.value)}
                className="w-full bg-slate-900 border border-slate-600 rounded-lg py-3 pl-8 pr-4 text-white focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition-all"
                placeholder="0.00"
              />
            </div>
          </div>
        </div>

        <div className="pt-6 border-t border-slate-700">
          <div className="bg-slate-900 rounded-xl p-6 text-center space-y-2">
            <p className="text-slate-400 text-sm uppercase tracking-wider font-semibold">Costo Total Estimado</p>
            <p className="text-4xl font-bold text-emerald-400 tracking-tight">
              {formatCurrency(landedCost)}
            </p>
            <p className="text-xs text-slate-500 pt-2">
              Basado en Tasa: {config.exchangeRate} • Courier: {config.courierRate}/lb • Empaque: {config.packaging}
            </p>
          </div>
        </div>

        <div className="flex justify-center">
            <button 
                onClick={() => { setUsd(''); setWeight(''); }}
                className="text-slate-400 hover:text-white flex items-center gap-2 text-sm transition-colors"
            >
                <RefreshCw size={14} /> Limpiar campos
            </button>
        </div>
      </div>
    </div>
  );
};

export default Calculator;