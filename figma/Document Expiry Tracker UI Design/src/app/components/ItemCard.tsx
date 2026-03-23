import { Link } from 'react-router';
import { CategoryIcon } from './CategoryIcon';
import { StatusBadge } from './StatusBadge';
import { ChevronRight } from 'lucide-react';
import { Item, getItemStatus, getCountdownText, formatDate, getCategoryColor } from '../data/mockData';

interface ItemCardProps {
  item: Item;
}

export function ItemCard({ item }: ItemCardProps) {
  const status = getItemStatus(item);
  const countdownText = getCountdownText(item.dueDate);
  const categoryColor = getCategoryColor(item.category);

  return (
    <Link to={`item/${item.id}`}>
      <div className="bg-[#1C1C1E] rounded-xl p-4 border border-white/10 active:bg-[#2C2C2E] transition-colors">
        <div className="flex items-start gap-3">
          <div 
            className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
            style={{ backgroundColor: `${categoryColor}20` }}
          >
            <CategoryIcon 
              category={item.category} 
              size={20} 
              className="text-current"
              style={{ color: categoryColor }}
            />
          </div>
          
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2">
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-[15px] text-white truncate">
                  {item.title}
                </h3>
                {item.provider && (
                  <p className="text-sm text-gray-400 truncate mt-0.5">
                    {item.provider}
                  </p>
                )}
              </div>
              <ChevronRight className="w-5 h-5 text-gray-600 flex-shrink-0 mt-0.5" />
            </div>
            
            <div className="flex items-center gap-2 mt-2.5">
              <StatusBadge status={status} text={countdownText} size="sm" />
              {item.amount && (
                <span className="text-xs text-gray-400">
                  {item.currency} {item.amount.toFixed(2)}
                  {item.isRecurring && item.recurringInterval && (
                    <span className="text-gray-500">
                      {' '}/ {item.recurringInterval === 'monthly' ? 'mo' : item.recurringInterval === 'yearly' ? 'yr' : 'qtr'}
                    </span>
                  )}
                </span>
              )}
            </div>
            
            <p className="text-xs text-gray-500 mt-1.5">
              Due {formatDate(item.dueDate)}
            </p>
          </div>
        </div>
      </div>
    </Link>
  );
}