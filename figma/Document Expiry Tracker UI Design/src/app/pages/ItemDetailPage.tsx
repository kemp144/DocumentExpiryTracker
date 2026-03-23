import { useParams, useNavigate, Link } from 'react-router';
import { ArrowLeft, Edit2, Archive, Trash2, Calendar, DollarSign, FileText, Bell, Repeat } from 'lucide-react';
import { CategoryIcon } from '../components/CategoryIcon';
import { StatusBadge } from '../components/StatusBadge';
import { Button } from '../components/Button';
import { mockItems, getItemStatus, getCountdownText, formatDate, getCategoryColor } from '../data/mockData';

export function ItemDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  
  const item = mockItems.find(i => i.id === id);
  
  if (!item) {
    return (
      <div className="max-w-md mx-auto px-4 pt-6">
        <p>Item not found</p>
      </div>
    );
  }
  
  const status = getItemStatus(item);
  const countdownText = getCountdownText(item.dueDate);
  const categoryColor = getCategoryColor(item.category);

  return (
    <div className="min-h-screen bg-[#0A0A0A] pb-8">
      {/* Header */}
      <div className="bg-[#1C1C1E] border-b border-white/10">
        <div className="max-w-md mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            <button 
              onClick={() => navigate(-1)}
              className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center active:bg-white/10 transition-colors"
            >
              <ArrowLeft className="w-6 h-6 text-[#0A84FF]" />
            </button>
            <Link to={`/edit/${item.id}`}>
              <button className="px-4 py-2 text-[#0A84FF] font-medium text-[15px] active:opacity-70">
                Edit
              </button>
            </Link>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4 pt-6">
        {/* Main Info Card */}
        <div className="bg-[#1C1C1E] rounded-2xl p-6 border border-white/10 mb-4">
          <div className="flex items-start gap-4 mb-4">
            <div 
              className="w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0"
              style={{ backgroundColor: `${categoryColor}20` }}
            >
              <CategoryIcon 
                category={item.category} 
                size={28} 
                style={{ color: categoryColor }}
              />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm text-gray-400 mb-1 capitalize">{item.category}</p>
              <h1 className="text-2xl font-bold text-white mb-1">
                {item.title}
              </h1>
              {item.provider && (
                <p className="text-[15px] text-gray-400">{item.provider}</p>
              )}
            </div>
          </div>
          
          <div className="pt-4 border-t border-white/10">
            <StatusBadge status={status} text={countdownText} size="md" />
          </div>
        </div>

        {/* Details */}
        <div className="bg-[#1C1C1E] rounded-2xl border border-white/10 mb-4 overflow-hidden">
          {/* Due Date */}
          <div className="p-4 border-b border-white/10">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center">
                <Calendar className="w-5 h-5 text-gray-400" />
              </div>
              <div>
                <p className="text-sm text-gray-400">Due Date</p>
                <p className="font-semibold text-white">{formatDate(item.dueDate)}</p>
              </div>
            </div>
          </div>

          {/* Recurring */}
          {item.isRecurring && (
            <div className="p-4 border-b border-white/10">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center">
                  <Repeat className="w-5 h-5 text-gray-400" />
                </div>
                <div>
                  <p className="text-sm text-gray-400">Recurring</p>
                  <p className="font-semibold text-white capitalize">
                    {item.recurringInterval}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Amount */}
          {item.amount && (
            <div className="p-4 border-b border-white/10">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center">
                  <DollarSign className="w-5 h-5 text-gray-400" />
                </div>
                <div>
                  <p className="text-sm text-gray-400">Amount</p>
                  <p className="font-semibold text-white">
                    {item.currency} {item.amount.toFixed(2)}
                    {item.isRecurring && item.recurringInterval && (
                      <span className="text-gray-500 font-normal">
                        {' '}/ {item.recurringInterval}
                      </span>
                    )}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Owner */}
          {item.owner && (
            <div className="p-4 border-b border-white/10">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center">
                  <FileText className="w-5 h-5 text-gray-400" />
                </div>
                <div>
                  <p className="text-sm text-gray-400">Owner</p>
                  <p className="font-semibold text-white">{item.owner}</p>
                </div>
              </div>
            </div>
          )}

          {/* Reminders */}
          {item.reminders && item.reminders.length > 0 && (
            <div className="p-4">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center">
                  <Bell className="w-5 h-5 text-gray-400" />
                </div>
                <div>
                  <p className="text-sm text-gray-400 mb-1">Reminders</p>
                  <div className="flex flex-wrap gap-2">
                    {item.reminders.map(days => (
                      <span key={days} className="px-2.5 py-1 bg-white/5 text-gray-400 text-xs rounded-full">
                        {days === 0 ? 'Same day' : `${days} day${days > 1 ? 's' : ''} before`}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Notes */}
        {item.notes && (
          <div className="bg-[#1C1C1E] rounded-2xl p-4 border border-white/10 mb-6">
            <h3 className="text-sm font-semibold text-white mb-2">Notes</h3>
            <p className="text-[15px] text-gray-400 leading-relaxed">
              {item.notes}
            </p>
          </div>
        )}

        {/* Actions */}
        <div className="space-y-2">
          <Link to={`/edit/${item.id}`} className="block">
            <button className="w-full flex items-center justify-center gap-2 bg-[#1C1C1E] border border-white/10 rounded-xl py-3 text-[#0A84FF] font-medium active:bg-[#2C2C2E] transition-colors">
              <Edit2 className="w-5 h-5" />
              <span>Edit Item</span>
            </button>
          </Link>
          
          <button className="w-full flex items-center justify-center gap-2 bg-[#1C1C1E] border border-white/10 rounded-xl py-3 text-gray-400 font-medium active:bg-[#2C2C2E] transition-colors">
            <Archive className="w-5 h-5" />
            <span>Archive</span>
          </button>
          
          <button className="w-full flex items-center justify-center gap-2 bg-[#1C1C1E] border border-[#FF453A]/30 rounded-xl py-3 text-[#FF453A] font-medium active:bg-[#FF453A]/10 transition-colors">
            <Trash2 className="w-5 h-5" />
            <span>Delete</span>
          </button>
        </div>
      </div>
    </div>
  );
}