import { Order } from './types';
import OrderCard from './OrderCard';
import { useDroppable } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

interface KanbanColumnProps {
    title: string;
    orders: Order[];
    colorClass: string;
    emptyMessage: string;
    onPrint: (order: Order) => void;
    onAction: (order: Order) => void;
    getActionLabel: (order: Order) => string;
    getActionIcon: (order: Order) => React.ReactNode;
    columnId: string;
}

function SortableOrderCard({
    order,
    onPrint,
    onAction,
    actionLabel,
    actionIcon
}: {
    order: Order;
    onPrint: () => void;
    onAction: () => void;
    actionLabel: string;
    actionIcon: React.ReactNode;
}) {
    const {
        attributes,
        listeners,
        setNodeRef,
        transform,
        transition,
        isDragging,
    } = useSortable({ id: order.id });

    const style = {
        transform: CSS.Transform.toString(transform),
        transition,
        opacity: isDragging ? 0.5 : 1,
    };

    return (
        <div ref={setNodeRef} style={style} {...attributes} {...listeners}>
            <OrderCard
                order={order}
                onPrint={onPrint}
                onAction={onAction}
                actionLabel={actionLabel}
                actionIcon={actionIcon}
            />
        </div>
    );
}

export default function KanbanColumn({
    title,
    orders,
    colorClass,
    emptyMessage,
    onPrint,
    onAction,
    getActionLabel,
    getActionIcon,
    columnId
}: KanbanColumnProps) {
    const { setNodeRef } = useDroppable({ id: columnId });

    return (
        <div className="flex-1 min-w-[320px]">
            <div className="flex items-center gap-2 mb-4">
                <h2 className="text-sm font-bold text-slate-300 uppercase tracking-wide">{title}</h2>
                <span className={`px-2 py-0.5 rounded text-xs font-semibold bg-${colorClass}-500/20 text-${colorClass}-400 border border-${colorClass}-500/30`}>
                    {orders.length}
                </span>
            </div>

            <div
                ref={setNodeRef}
                className="space-y-3 min-h-[400px] rounded-lg p-1"
            >
                <SortableContext items={orders.map(o => o.id)} strategy={verticalListSortingStrategy}>
                    {orders.length === 0 ? (
                        <div className="flex items-center justify-center h-32 text-slate-600 text-sm italic">
                            {emptyMessage}
                        </div>
                    ) : (
                        orders.map(order => (
                            <SortableOrderCard
                                key={order.id}
                                order={order}
                                onPrint={() => onPrint(order)}
                                onAction={() => onAction(order)}
                                actionLabel={getActionLabel(order)}
                                actionIcon={getActionIcon(order)}
                            />
                        ))
                    )}
                </SortableContext>
            </div>
        </div>
    );
}
