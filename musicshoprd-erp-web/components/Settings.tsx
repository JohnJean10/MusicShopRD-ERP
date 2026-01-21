import React, { useState, useEffect } from 'react';
import { AppConfigState } from '../types';
import { Save, Settings as SettingsIcon } from 'lucide-react';

interface SettingsProps {
  config: AppConfigState;
  onUpdate: (newConfig: AppConfigState) => void;
}

const Settings: React.FC<SettingsProps> = ({ config, onUpdate }) => {
  const [localConfig, setLocalConfig] = useState<AppConfigState>(config);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    setLocalConfig(config);
  }, [config]);

  const handleChange = (key: keyof AppConfigState, value: string) => {
    setLocalConfig(prev => ({
      ...prev,
      [key]: parseFloat(value) || 0
    }));
    setSaved(false);
  };

  const handleSave = () => {
    onUpdate(localConfig);
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="max-w-2xl mx-auto pt-8">
      <h2 className="text-2xl font-bold text-emerald-400 mb-6 flex items-center gap-2">
        <SettingsIcon className="w-6 h-6" />
        Configuración de Tasas
      </h2>

      <div className="bg-slate-800 p-8 rounded-2xl border border-slate-700 shadow-xl space-y-6">
        
        <div className="space-y-4">
          <div className="grid grid-cols-1 gap-1">
            <label className="text-sm font-medium text-slate-300">Tasa del Dólar (DOP)</label>
            <input
              type="number"
              value={localConfig.exchangeRate}
              onChange={(e) => handleChange('exchangeRate', e.target.value)}
              className="bg-slate-900 border border-slate-600 rounded-lg p-3 text-white focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none transition-all"
            />
            <p className="text-xs text-slate-500">Valor actual de 1 USD en Pesos Dominicanos.</p>
          </div>

          <div className="grid grid-cols-1 gap-1">
            <label className="text-sm font-medium text-slate-300">Costo Courier (por Libra)</label>
            <input
              type="number"
              value={localConfig.courierRate}
              onChange={(e) => handleChange('courierRate', e.target.value)}
              className="bg-slate-900 border border-slate-600 rounded-lg p-3 text-white focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none transition-all"
            />
            <p className="text-xs text-slate-500">Tarifa por libra de importación aérea.</p>
          </div>

          <div className="grid grid-cols-1 gap-1">
            <label className="text-sm font-medium text-slate-300">Empaque y Gestión (Fijo)</label>
            <input
              type="number"
              value={localConfig.packaging}
              onChange={(e) => handleChange('packaging', e.target.value)}
              className="bg-slate-900 border border-slate-600 rounded-lg p-3 text-white focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none transition-all"
            />
            <p className="text-xs text-slate-500">Costo fijo administrativo o de materiales por artículo.</p>
          </div>
        </div>

        <div className="pt-4 flex items-center justify-between">
            <p className={`text-sm ${saved ? 'text-emerald-400' : 'text-transparent'} transition-colors duration-300`}>
                ¡Configuración guardada exitosamente!
            </p>
            <button
                onClick={handleSave}
                className="bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-3 rounded-lg font-medium flex items-center gap-2 transition-all transform active:scale-95 shadow-lg shadow-emerald-900/20"
            >
                <Save size={18} />
                Guardar Cambios
            </button>
        </div>
      </div>
    </div>
  );
};

export default Settings;