import { useState } from 'react';
import { Order, OrderStatus, Product } from './types';
import KanbanColumn from './KanbanColumn';
import CreateOrderModal from './components/CreateOrderModal';
import { DndContext, DragEndEvent, PointerSensor, useSensor, useSensors, closestCenter } from '@dnd-kit/core';
import { Plus, CheckCircle, Clock, PackageCheck, Printer } from 'lucide-react';

interface OrdersKanbanProps {
    orders: Order[];
    products: Product[];
    onCreateOrder: (order: Order) => void;
    onUpdateOrder: (order: Order) => void;
    onPrintOrder: (order: Order, isQuote: boolean) => void;
}

export default function OrdersKanban({ orders, products, onCreateOrder, onUpdateOrder, onPrintOrder }: OrdersKanbanProps) {
    const [searchTerm, setSearchTerm] = useState('');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [modalIsQuote, setModalIsQuote] = useState(false);

    const sensors = useSensors(
        useSensor(PointerSensor, {
            activationConstraint: {
                distance: 8,
            },
        })
    );

    const filteredOrders = orders.filter(o =>
        o.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        o.id.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const columns = {
        prospects: {
            title: 'PROSPECTOS / INTERESADOS',
            statuses: [OrderStatus.quote],
            colorClass: 'blue',
            emptyMessage: 'Sin cotizaciones',
        },
        inProgress: {
            title: 'EN PROCESO / PAGADOS',
            statuses: [OrderStatus.pending, OrderStatus.ready],
            colorClass: 'orange',
            emptyMessage: 'Sin pedidos en proceso',
        },
        completed: {
            title: 'FINALIZADOS',
            statuses: [OrderStatus.completed, OrderStatus.cancelled],
            colorClass: 'green',
            emptyMessage: 'Sin pedidos finalizados',
        },
    };

    const getOrdersByColumn = (columnId: keyof typeof columns) => {
        return filteredOrders.filter(o => columns[columnId].statuses.includes(o.status));
    };

    const getActionLabel = (order: Order): string => {
        switch (order.status) {
            case OrderStatus.quote:
                return 'Dar seguimiento';
            case OrderStatus.pending:
                return 'Confirmar llegada';
            case OrderStatus.ready:
                return 'Preparar envío';
            default:
                return 'Ver detalles';
        }
    };

    const getActionIcon = (order: Order) => {
        switch (order.status) {
            case OrderStatus.quote:
                return <Clock className="w-4 h-4" />;
            case OrderStatus.pending:
                return <CheckCircle className="w-4 h-4" />;
            case OrderStatus.ready:
                return <PackageCheck className="w-4 h-4" />;
            default:
                return <Printer className="w-4 h-4" />;
        }
    };

    const handleAction = (order: Order) => {
        let newStatus: OrderStatus;
        switch (order.status) {
            case OrderStatus.quote:
                newStatus = OrderStatus.pending;
                break;
            case OrderStatus.pending:
                newStatus = OrderStatus.ready;
                break;
            case OrderStatus.ready:
                newStatus = OrderStatus.completed;
                break;
            default:
                return;
        }
        onUpdateOrder({ ...order, status: newStatus });
    };

    const handleDragEnd = (event: DragEndEvent) => {
        const { active, over } = event;

        if (!over) return;

        const activeId = active.id as string;
        const overId = over.id as string;

        const draggedOrder = orders.find(o => o.id === activeId);
        if (!draggedOrder) return;

        let targetStatus: OrderStatus | null = null;

        if (overId === 'prospects' || columns.prospects.statuses.includes(orders.find(o => o.id === overId)?.status as OrderStatus)) {
            targetStatus = OrderStatus.quote;
        } else if (overId === 'inProgress' || columns.inProgress.statuses.includes(orders.find(o => o.id === overId)?.status as OrderStatus)) {
            targetStatus = draggedOrder.status === OrderStatus.quote ? OrderStatus.pending : draggedOrder.status;
        } else if (overId === 'completed' || columns.completed.statuses.includes(orders.find(o => o.id === overId)?.status as OrderStatus)) {
            targetStatus = OrderStatus.completed;
        }

        if (targetStatus && targetStatus !== draggedOrder.status) {
            onUpdateOrder({ ...draggedOrder, status: targetStatus });
        }
    };

    const handleOpenModal = (isQuote: boolean) => {
        setModalIsQuote(isQuote);
        setIsModalOpen(true);
    };

    const handleSaveOrder = (order: Order) => {
        onCreateOrder(order);
    };

    return (
        <div className="p-6">
            {/* Header */}
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-emerald-400">Tablero de Pedidos</h1>
                <div className="flex gap-2">
                    <button
                        onClick={() => handleOpenModal(true)}
                        className="px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg flex items-center gap-2 text-sm font-medium transition-colors"
                    >
                        <Plus className="w-4 h-4" />
                        Nueva Cotización
                    </button>
                    <button
                        onClick={() => handleOpenModal(false)}
                        className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg flex items-center gap-2 text-sm font-medium transition-colors"
                    >
                        <Plus className="w-4 h-4" />
                        Nuevo Pedido
                    </button>
                </div>
            </div>

            {/* Search */}
            <div className="mb-6">
                <input
                    type="text"
                    placeholder="Buscar cliente o ID..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full max-w-md px-4 py-2 bg-slate-800 text-white rounded-lg border border-slate-700 focus:border-emerald-500 focus:outline-none"
                />
            </div>

            {/* Kanban Board */}
            <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
                <div className="flex gap-4 overflow-x-auto pb-4">
                    <KanbanColumn
                        columnId="prospects"
                        title={columns.prospects.title}
                        orders={getOrdersByColumn('prospects')}
                        colorClass={columns.prospects.colorClass}
                        emptyMessage={columns.prospects.emptyMessage}
                        onPrint={(order) => onPrintOrder(order, true)}
                        onAction={handleAction}
                        getActionLabel={getActionLabel}
                        getActionIcon={getActionIcon}
                    />
                    <KanbanColumn
                        columnId="inProgress"
                        title={columns.inProgress.title}
                        orders={getOrdersByColumn('inProgress')}
                        colorClass={columns.inProgress.colorClass}
                        emptyMessage={columns.inProgress.emptyMessage}
                        onPrint={(order) => onPrintOrder(order, false)}
                        onAction={handleAction}
                        getActionLabel={getActionLabel}
                        getActionIcon={getActionIcon}
                    />
                    <KanbanColumn
                        columnId="completed"
                        title={columns.completed.title}
                        orders={getOrdersByColumn('completed')}
                        colorClass={columns.completed.colorClass}
                        emptyMessage={columns.completed.emptyMessage}
                        onPrint={(order) => onPrintOrder(order, false)}
                        onAction={handleAction}
                        getActionLabel={getActionLabel}
                        getActionIcon={getActionIcon}
                    />
                </div>
            </DndContext>

            {/* Modal */}
            <CreateOrderModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                products={products}
                onSave={handleSaveOrder}
                isQuote={modalIsQuote}
            />
        </div>
    );
}
