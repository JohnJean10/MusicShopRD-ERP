import React, { useState } from 'react';
import { Order, Product } from '../types';
import { Plus, Search, ShoppingBag, Trash2, Filter, AlertCircle, Clock, CheckCircle2, XCircle, ArrowRight } from 'lucide-react';
import CreateOrderModal from './CreateOrderModal';

interface OrdersProps {
  orders: Order[];
  products: Product[];
  onCreateOrder: (order: Order) => void;
  onUpdateOrder: (order: Order) => void;
  onDeleteOrder: (id: string) => void;
}

type TabType = 'active' | 'quotes' | 'history';

const Orders: React.FC<OrdersProps> = ({ orders, products, onCreateOrder, onUpdateOrder, onDeleteOrder }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [activeTab, setActiveTab] = useState<TabType>('active');

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-DO', { style: 'currency', currency: 'DOP' }).format(amount);
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('es-DO', {
      day: 'numeric',
      month: 'short',
    });
  };

  // Filter Logic
  const filteredOrders = orders.filter(o => {
    const matchesSearch = o.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          o.id.toLowerCase().includes(searchTerm.toLowerCase());
    
    if (!matchesSearch) return false;

    if (activeTab === 'quotes') return o.status === 'quote';
    if (activeTab === 'active') return o.status === 'pending' || o.status === 'ready';
    if (activeTab === 'history') return o.status === 'completed' || o.status === 'cancelled';
    
    return true;
  }).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

  const getStatusBadge = (status: Order['status']) => {
    switch (status) {
      case 'quote': return <span className="px-2 py-1 rounded-full text-xs font-medium border bg-blue-500/10 text-blue-400 border-blue-500/20">Cotización</span>;
      case 'pending': return <span className="px-2 py-1 rounded-full text-xs font-medium border bg-orange-500/10 text-orange-400 border-orange-500/20">Pendiente</span>;
      case 'ready': return <span className="px-2 py-1 rounded-full text-xs font-medium border bg-yellow-500/10 text-yellow-400 border-yellow-500/20">Listo Entrega</span>;
      case 'completed': return <span className="px-2 py-1 rounded-full text-xs font-medium border bg-emerald-500/10 text-emerald-400 border-emerald-500/20">Completado</span>;
      case 'cancelled': return <span className="px-2 py-1 rounded-full text-xs font-medium border bg-red-500/10 text-red-400 border-red-500/20">Cancelado</span>;
    }
  };

  const getAlertMessage = (order: Order) => {
      switch (order.status) {
          case 'quote':
              return <div className="flex items-center gap-1 text-blue-400"><Clock size={14}/> <span>Seguimiento Cliente</span></div>;
          case 'pending':
              return <div className="flex items-center gap-1 text-orange-400"><AlertCircle size={14}/> <span>Falta Pago/Prep.</span></div>;
          case 'ready':
              return <div className="flex items-center gap-1 text-yellow-400"><CheckCircle2 size={14}/> <span>Coordinar Retiro</span></div>;
          case 'completed':
              return <span className="text-slate-500 text-xs">Finalizado</span>;
          case 'cancelled':
              return <span className="text-slate-500 text-xs">Cerrado</span>;
      }
  };

  const handleStatusChange = (order: Order, newStatus: Order['status']) => {
      onUpdateOrder({ ...order, status: newStatus });
  };

  return (
    <div className="space-y-4 h-full flex flex-col">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h2 className="text-2xl font-bold text-emerald-400">Control de Pedidos</h2>
        <button 
          onClick={() => setIsModalOpen(true)}
          className="flex items-center justify-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg transition-colors shadow-lg shadow-emerald-900/50"
        >
          <Plus size={18} />
          <span>Nuevo Pedido</span>
        </button>
      </div>

      {/* Tabs */}
      <div className="flex space-x-1 bg-slate-800 p-1 rounded-xl w-fit">
          <button 
            onClick={() => setActiveTab('quotes')}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${activeTab === 'quotes' ? 'bg-slate-700 text-white shadow-sm' : 'text-slate-400 hover:text-white'}`}
          >
              Cotizaciones
          </button>
          <button 
            onClick={() => setActiveTab('active')}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${activeTab === 'active' ? 'bg-slate-700 text-white shadow-sm' : 'text-slate-400 hover:text-white'}`}
          >
              En Proceso
          </button>
          <button 
            onClick={() => setActiveTab('history')}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${activeTab === 'history' ? 'bg-slate-700 text-white shadow-sm' : 'text-slate-400 hover:text-white'}`}
          >
              Histórico
          </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
        <input 
          type="text" 
          placeholder="Buscar cliente, ID o producto..." 
          className="w-full bg-slate-800 border border-slate-700 text-white rounded-lg pl-10 pr-4 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {/* Table */}
      <div className="flex-1 overflow-auto bg-slate-800 rounded-xl border border-slate-700 shadow-lg">
        <table className="w-full text-left border-collapse">
          <thead className="bg-slate-900/50 sticky top-0 z-10">
            <tr>
              <th className="p-4 text-slate-400 font-semibold text-sm">Cliente / ID</th>
              <th className="p-4 text-slate-400 font-semibold text-sm hidden md:table-cell">Fecha</th>
              <th className="p-4 text-slate-400 font-semibold text-sm">Estado</th>
              <th className="p-4 text-slate-400 font-semibold text-sm">Alerta / Acción</th>
              <th className="p-4 text-slate-400 font-semibold text-sm text-right">Total</th>
              <th className="p-4 text-slate-400 font-semibold text-sm text-center">Gestión</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-700">
            {filteredOrders.map((order) => (
              <tr key={order.id} className="hover:bg-slate-700/30 transition-colors">
                <td className="p-4">
                    <div className="font-medium text-white">{order.customerName}</div>
                    <div className="font-mono text-xs text-slate-500">#{order.id.slice(0, 8)}</div>
                    <div className="text-xs text-slate-400 mt-1 md:hidden">{formatDate(order.date)}</div>
                </td>
                <td className="p-4 text-slate-400 text-sm hidden md:table-cell">{formatDate(order.date)}</td>
                <td className="p-4">
                  {getStatusBadge(order.status)}
                </td>
                <td className="p-4 text-sm font-medium">
                    {getAlertMessage(order)}
                </td>
                <td className="p-4 text-right font-bold text-emerald-400">
                  {formatCurrency(order.total)}
                </td>
                <td className="p-4 text-center">
                    <div className="flex items-center justify-center gap-2">
                        {/* Action Buttons based on Status */}
                        {order.status === 'quote' && (
                            <button title="Confirmar Pedido" onClick={() => handleStatusChange(order, 'pending')} className="bg-emerald-600/20 hover:bg-emerald-600 text-emerald-400 hover:text-white p-2 rounded-lg transition-colors">
                                <CheckCircle2 size={16} />
                            </button>
                        )}
                        {order.status === 'pending' && (
                            <button title="Marcar Listo" onClick={() => handleStatusChange(order, 'ready')} className="bg-yellow-600/20 hover:bg-yellow-600 text-yellow-400 hover:text-white p-2 rounded-lg transition-colors">
                                <ArrowRight size={16} />
                            </button>
                        )}
                        {order.status === 'ready' && (
                            <button title="Entregar y Finalizar" onClick={() => handleStatusChange(order, 'completed')} className="bg-blue-600/20 hover:bg-blue-600 text-blue-400 hover:text-white p-2 rounded-lg transition-colors">
                                <CheckCircle2 size={16} />
                            </button>
                        )}
                        {(order.status === 'quote' || order.status === 'pending' || order.status === 'ready') && (
                            <button title="Cancelar" onClick={() => handleStatusChange(order, 'cancelled')} className="bg-red-600/20 hover:bg-red-600 text-red-400 hover:text-white p-2 rounded-lg transition-colors">
                                <XCircle size={16} />
                            </button>
                        )}
                        
                        <button onClick={() => onDeleteOrder(order.id)} className="p-2 text-slate-500 hover:text-red-400 transition-colors" title="Borrar Registro">
                            <Trash2 size={16} />
                        </button>
                    </div>
                </td>
              </tr>
            ))}
            {filteredOrders.length === 0 && (
              <tr>
                <td colSpan={6} className="p-12 text-center text-slate-500">
                  <Filter className="w-12 h-12 mx-auto mb-3 opacity-30" />
                  <p>No hay pedidos en esta vista.</p>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <CreateOrderModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        products={products}
        onSave={onCreateOrder}
      />
    </div>
  );
};

export default Orders;