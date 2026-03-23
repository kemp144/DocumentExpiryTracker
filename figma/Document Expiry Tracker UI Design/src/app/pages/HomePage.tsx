import { Plus, Calendar, AlertCircle, Clock } from 'lucide-react';
import { Link } from 'react-router';
import { ItemCard } from '../components/ItemCard';
import { EmptyState } from '../components/EmptyState';
import { mockItems, getItemStatus } from '../data/mockData';

export function HomePage() {
  // For demo, show empty state when no items, populated when items exist
  const hasItems = mockItems.length > 0;
  
  const expiredItems = mockItems.filter(item => getItemStatus(item) === 'expired');
  const dueSoonItems = mockItems.filter(item => getItemStatus(item) === 'due-soon');
  const upcomingItems = mockItems.filter(item => {
    const status = getItemStatus(item);
    const dueDate = new Date(item.dueDate);
    const today = new Date();
    const daysUntil = Math.ceil((dueDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    return status === 'active' && daysUntil <= 30;
  });
  
  const monthlyRecurringTotal = mockItems
    .filter(item => item.isRecurring && item.recurringInterval === 'monthly' && item.amount)
    .reduce((sum, item) => sum + (item.amount || 0), 0);
    
  const yearlyRecurringTotal = mockItems
    .filter(item => item.isRecurring && item.recurringInterval === 'yearly' && item.amount)
    .reduce((sum, item) => sum + (item.amount || 0), 0);

  return (
    <div className="max-w-md mx-auto px-4 pt-6 pb-8">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-start justify-between mb-2">
          <div>
            <h1 className="text-[28px] font-bold text-white tracking-tight">
              Home
            </h1>
            <p className="text-[15px] text-gray-400 mt-1">
              Track what matters, stay organized
            </p>
          </div>
          <Link 
            to="/add"
            className="w-10 h-10 rounded-full bg-[#0A84FF] flex items-center justify-center active:bg-[#0066CC] transition-colors"
          >
            <Plus className="w-5 h-5 text-white" strokeWidth={2.5} />
          </Link>
        </div>
      </div>

      {!hasItems ? (
        /* Empty State */
        <div className="mt-12">
          <EmptyState
            icon={Calendar}
            title="No items yet"
            description="Add your first document, subscription, or renewal to get started."
            actionLabel="Add First Item"
            actionPath="/add"
          />
        </div>
      ) : (
        /* Populated State */
        <>
          {/* Summary Card */}
          <div className="bg-gradient-to-br from-[#0A84FF] to-[#5E5CE6] rounded-2xl p-6 mb-6 text-white shadow-lg">
            <div className="flex items-start justify-between mb-4">
              <div>
                <p className="text-white/70 text-sm mb-1">Overview</p>
                <h2 className="text-2xl font-bold">{mockItems.length} Items</h2>
              </div>
              <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center">
                <Calendar className="w-6 h-6" />
              </div>
            </div>
            
            <div className="grid grid-cols-3 gap-3 pt-4 border-t border-white/20">
              <div>
                <p className="text-white/60 text-xs mb-1">Expired</p>
                <p className="text-xl font-semibold">{expiredItems.length}</p>
              </div>
              <div>
                <p className="text-white/60 text-xs mb-1">Due Soon</p>
                <p className="text-xl font-semibold">{dueSoonItems.length}</p>
              </div>
              <div>
                <p className="text-white/60 text-xs mb-1">Active</p>
                <p className="text-xl font-semibold">
                  {mockItems.length - expiredItems.length - dueSoonItems.length}
                </p>
              </div>
            </div>
          </div>

          {/* Expired Items */}
          {expiredItems.length > 0 && (
            <div className="mb-6">
              <div className="flex items-center gap-2 mb-3">
                <AlertCircle className="w-5 h-5 text-[#FF453A]" />
                <h2 className="text-[17px] font-semibold text-white">
                  Expired
                </h2>
                <span className="text-sm text-gray-400">
                  {expiredItems.length}
                </span>
              </div>
              <div className="space-y-2">
                {expiredItems.map(item => (
                  <ItemCard key={item.id} item={item} />
                ))}
              </div>
            </div>
          )}

          {/* Due Soon */}
          {dueSoonItems.length > 0 && (
            <div className="mb-6">
              <div className="flex items-center gap-2 mb-3">
                <Clock className="w-5 h-5 text-[#FF9F0A]" />
                <h2 className="text-[17px] font-semibold text-white">
                  Due Soon
                </h2>
                <span className="text-sm text-gray-400">
                  {dueSoonItems.length}
                </span>
              </div>
              <div className="space-y-2">
                {dueSoonItems.map(item => (
                  <ItemCard key={item.id} item={item} />
                ))}
              </div>
            </div>
          )}

          {/* Upcoming This Month */}
          {upcomingItems.length > 0 && (
            <div className="mb-6">
              <h2 className="text-[17px] font-semibold text-white mb-3">
                Upcoming This Month
              </h2>
              <div className="space-y-2">
                {upcomingItems.slice(0, 3).map(item => (
                  <ItemCard key={item.id} item={item} />
                ))}
              </div>
            </div>
          )}

          {/* Recurring Summary */}
          {(monthlyRecurringTotal > 0 || yearlyRecurringTotal > 0) && (
            <div className="bg-[#1C1C1E] rounded-xl p-4 border border-white/10">
              <h3 className="text-[15px] font-semibold text-white mb-3">
                Recurring Costs
              </h3>
              <div className="space-y-2">
                {monthlyRecurringTotal > 0 && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-400">Monthly</span>
                    <span className="font-semibold text-white">
                      ${monthlyRecurringTotal.toFixed(2)}
                    </span>
                  </div>
                )}
                {yearlyRecurringTotal > 0 && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-400">Yearly</span>
                    <span className="font-semibold text-white">
                      ${yearlyRecurringTotal.toFixed(2)}
                    </span>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Quick Add CTA */}
          <Link to="/add">
            <div className="bg-[#1C1C1E] rounded-xl p-4 border border-white/10 mt-6 active:bg-[#2C2C2E] transition-colors">
              <div className="flex items-center justify-center gap-2 text-[#0A84FF]">
                <Plus className="w-5 h-5" strokeWidth={2} />
                <span className="font-medium text-[15px]">Add New Item</span>
              </div>
            </div>
          </Link>
        </>
      )}
    </div>
  );
}