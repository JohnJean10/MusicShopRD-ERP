import { Order, OrderStatus } from './types';
import { X, FileText, CheckCircle, Clock } from 'lucide-react';

interface OrderCardProps {
  order: Order;
  onPrint: () => void;
  onAction: () => void;
  actionLabel: string;
  actionIcon: React.ReactNode;
}

export default function OrderCard({ order, onPrint, onAction, actionLabel, actionIcon }: OrderCardProps) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-DO', { style: 'currency', currency: 'DOP' }).format(amount);
  };

  const formatDate = (date: Date) => {
    return new Intl.DateFormat('es-DO', { month: 'short', day: 'numeric' }).format(date);
  };

  const getStatusBadge = () => {
    const statusConfig = {
      quote: { label: 'INTERESADO', color: 'bg-blue-500/20 text-blue-400 border-blue-500/30' },
      pending: { label: 'PREVENTA (50%)', color: 'bg-orange-500/20 text-orange-400 border-orange-500/30' },
      ready: { label: 'PAGADO', color: 'bg-green-500/20 text-green-400 border-green-500/30' },
      completed: { label: 'COMPLETADO', color: 'bg-gray-500/20 text-gray-400 border-gray-500/30' },
      cancelled: { label: 'CANCELADO', color: 'bg-red-500/20 text-red-400 border-red-500/30' },
    };

    const config = statusConfig[order.status];
    return (
      <span className={`px-2 py-1 text-xs font-semibold rounded border ${config.color}`}>
        {config.label}
      </span>
    );
  };

  return (
    <div className="bg-slate-800 rounded-lg p-4 border border-slate-700 hover:border-emerald-500/50 transition-all cursor-pointer group">
      <div className="flex justify-between items-start mb-3">
        <div className="flex-1">
          <h3 className="text-white font-semibold text-base mb-1">{order.customerName}</h3>
          <p className="text-slate-500 text-xs font-mono">{order.id.substring(0, 12)}</p>
        </div>
        <button
          onClick={onPrint}
          className="p-1.5 hover:bg-slate-700 rounded transition-colors"
          title="Imprimir PDF"
        >
          <FileText className="w-4 h-4 text-slate-400" />
        </button>
      </div>

      <div className="mb-3">
        {getStatusBadge()}
      </div>

      <div className="flex justify-between items-center mb-3">
        <span className="text-emerald-400 font-bold text-lg">{formatCurrency(order.total)}</span>
        <span className="text-slate-500 text-xs">{formatDate(order.date)}</span>
      </div>

      <button
        onClick={onAction}
        className="w-full flex items-center justify-center gap-2 py-2 px-3 bg-slate-700 hover:bg-slate-600 text-white rounded text-sm font-medium transition-colors"
      >
        {actionIcon}
        <span>{actionLabel}</span>
      </button>
    </div>
  );
}
