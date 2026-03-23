import { useState } from 'react';
import { Lock, TrendingUp, Calendar, DollarSign, PieChart } from 'lucide-react';
import { Link } from 'react-router';
import { mockItems, getItemStatus } from '../data/mockData';

export function InsightsPage() {
  const [isPro, setIsPro] = useState(false);
  
  const monthlyRecurringTotal = mockItems
    .filter(item => item.isRecurring && item.recurringInterval === 'monthly' && item.amount)
    .reduce((sum, item) => sum + (item.amount || 0), 0);
    
  const yearlyRecurringTotal = mockItems
    .filter(item => item.isRecurring && item.recurringInterval === 'yearly' && item.amount)
    .reduce((sum, item) => sum + (item.amount || 0), 0);
    
  const expiredCount = mockItems.filter(item => getItemStatus(item) === 'expired').length;
  const dueSoonCount = mockItems.filter(item => getItemStatus(item) === 'due-soon').length;
  
  const dueIn30Days = mockItems.filter(item => {
    const today = new Date();
    const dueDate = new Date(item.dueDate);
    const daysUntil = Math.ceil((dueDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    return daysUntil >= 0 && daysUntil <= 30;
  }).length;
  
  const categoryBreakdown = mockItems.reduce((acc, item) => {
    acc[item.category] = (acc[item.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  return (
    <div className="max-w-md mx-auto px-4 pt-6 pb-8">
      <div className="mb-6">
        <h1 className="text-[28px] font-bold text-white tracking-tight">
          Insights
        </h1>
        <p className="text-[15px] text-gray-400 mt-1">
          Track your renewal patterns and costs
        </p>
      </div>

      {!isPro ? (
        /* Locked Free Preview */
        <>
          {/* Quick Stats - Unlocked */}
          <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-white/10 mb-4">
            <h2 className="text-[17px] font-semibold text-white mb-4">
              Quick Stats
            </h2>
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-white/5 rounded-xl p-4">
                <p className="text-sm text-gray-400 mb-1">Total Items</p>
                <p className="text-2xl font-bold text-white">{mockItems.length}</p>
              </div>
              <div className="bg-white/5 rounded-xl p-4">
                <p className="text-sm text-gray-400 mb-1">Due Soon</p>
                <p className="text-2xl font-bold text-[#FF9F0A]">{dueSoonCount}</p>
              </div>
            </div>
          </div>

          {/* Locked Content */}
          <div className="relative">
            {/* Blur Effect */}
            <div className="filter blur-sm pointer-events-none select-none">
              <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-white/10 mb-4">
                <h2 className="text-[17px] font-semibold text-white mb-4">
                  Recurring Costs
                </h2>
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-[15px] text-gray-400">Monthly</span>
                    <span className="text-xl font-bold text-white">$XXX.XX</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-[15px] text-gray-400">Yearly</span>
                    <span className="text-xl font-bold text-white">$X,XXX.XX</span>
                  </div>
                </div>
              </div>

              <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-white/10 mb-4">
                <h2 className="text-[17px] font-semibold text-white mb-4">
                  Category Breakdown
                </h2>
                <div className="space-y-2">
                  {[1, 2, 3].map(i => (
                    <div key={i} className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-white/10"></div>
                      <div className="flex-1">
                        <div className="h-2 bg-white/10 rounded w-24 mb-1"></div>
                        <div className="h-1.5 bg-white/5 rounded w-16"></div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Unlock Overlay */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="bg-[#1C1C1E] rounded-2xl p-8 border border-white/20 shadow-2xl text-center max-w-xs">
                <div className="w-16 h-16 rounded-full bg-gradient-to-br from-[#0A84FF] to-[#5E5CE6] flex items-center justify-center mx-auto mb-4">
                  <Lock className="w-8 h-8 text-white" />
                </div>
                <h3 className="text-xl font-bold text-white mb-2">
                  Unlock Insights
                </h3>
                <p className="text-[15px] text-gray-400 mb-6 leading-relaxed">
                  Get detailed analytics, recurring cost tracking, and category breakdowns.
                </p>
                <Link to="/paywall">
                  <button className="w-full py-3 bg-[#0A84FF] text-white rounded-full font-semibold active:bg-[#0066CC] transition-colors mb-3">
                    Upgrade to Pro
                  </button>
                </Link>
                <button 
                  onClick={() => setIsPro(true)}
                  className="text-sm text-gray-500"
                >
                  Preview unlocked version
                </button>
              </div>
            </div>
          </div>
        </>
      ) : (
        /* Unlocked Pro Version */
        <>
          {/* Quick Stats */}
          <div className="bg-gradient-to-br from-[#0A84FF] to-[#5E5CE6] rounded-2xl p-5 mb-4 text-white shadow-lg">
            <div className="flex items-center gap-2 mb-4">
              <TrendingUp className="w-5 h-5" />
              <h2 className="text-[17px] font-semibold">Quick Stats</h2>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-white/20 rounded-xl p-4 backdrop-blur">
                <p className="text-sm text-white/80 mb-1">Total Items</p>
                <p className="text-2xl font-bold">{mockItems.length}</p>
              </div>
              <div className="bg-white/20 rounded-xl p-4 backdrop-blur">
                <p className="text-sm text-white/80 mb-1">Due in 30 Days</p>
                <p className="text-2xl font-bold">{dueIn30Days}</p>
              </div>
              <div className="bg-white/20 rounded-xl p-4 backdrop-blur">
                <p className="text-sm text-white/80 mb-1">Due Soon</p>
                <p className="text-2xl font-bold">{dueSoonCount}</p>
              </div>
              <div className="bg-white/20 rounded-xl p-4 backdrop-blur">
                <p className="text-sm text-white/80 mb-1">Expired</p>
                <p className="text-2xl font-bold">{expiredCount}</p>
              </div>
            </div>
          </div>

          {/* Recurring Costs */}
          <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-white/10 mb-4">
            <div className="flex items-center gap-2 mb-4">
              <DollarSign className="w-5 h-5 text-gray-400" />
              <h2 className="text-[17px] font-semibold text-white">
                Recurring Costs
              </h2>
            </div>
            <div className="space-y-4">
              <div>
                <div className="flex justify-between items-baseline mb-2">
                  <span className="text-[15px] text-gray-400">Monthly</span>
                  <span className="text-2xl font-bold text-white">
                    ${monthlyRecurringTotal.toFixed(2)}
                  </span>
                </div>
                <div className="h-2 bg-white/5 rounded-full overflow-hidden">
                  <div className="h-full bg-[#0A84FF] rounded-full" style={{ width: '70%' }}></div>
                </div>
              </div>
              <div>
                <div className="flex justify-between items-baseline mb-2">
                  <span className="text-[15px] text-gray-400">Yearly</span>
                  <span className="text-2xl font-bold text-white">
                    ${yearlyRecurringTotal.toFixed(2)}
                  </span>
                </div>
                <div className="h-2 bg-white/5 rounded-full overflow-hidden">
                  <div className="h-full bg-[#5E5CE6] rounded-full" style={{ width: '45%' }}></div>
                </div>
              </div>
              <div className="pt-3 border-t border-white/10">
                <div className="flex justify-between items-baseline">
                  <span className="text-[15px] font-medium text-white">Annual Total</span>
                  <span className="text-xl font-bold text-white">
                    ${(monthlyRecurringTotal * 12 + yearlyRecurringTotal).toFixed(2)}
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Category Breakdown */}
          <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-white/10 mb-4">
            <div className="flex items-center gap-2 mb-4">
              <PieChart className="w-5 h-5 text-gray-400" />
              <h2 className="text-[17px] font-semibold text-white">
                Category Breakdown
              </h2>
            </div>
            <div className="space-y-3">
              {Object.entries(categoryBreakdown).map(([category, count]) => {
                const percentage = (count / mockItems.length) * 100;
                const colors: Record<string, string> = {
                  document: '#0A84FF',
                  subscription: '#5E5CE6',
                  contract: '#30D158',
                  warranty: '#FF9F0A',
                  insurance: '#FF453A',
                  other: '#8E8E93'
                };
                return (
                  <div key={category}>
                    <div className="flex justify-between items-center mb-1.5">
                      <span className="text-[15px] text-white capitalize">{category}</span>
                      <span className="text-sm font-semibold text-gray-400">{count}</span>
                    </div>
                    <div className="h-2 bg-white/5 rounded-full overflow-hidden">
                      <div 
                        className="h-full rounded-full" 
                        style={{ 
                          width: `${percentage}%`,
                          backgroundColor: colors[category] || colors.other
                        }}
                      ></div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Upcoming Timeline */}
          <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-white/10">
            <div className="flex items-center gap-2 mb-4">
              <Calendar className="w-5 h-5 text-gray-400" />
              <h2 className="text-[17px] font-semibold text-white">
                Next 30 Days
              </h2>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between items-center py-2">
                <span className="text-[15px] text-gray-400">Due Soon</span>
                <span className="text-lg font-semibold text-[#FF9F0A]">{dueSoonCount}</span>
              </div>
              <div className="flex justify-between items-center py-2">
                <span className="text-[15px] text-gray-400">Coming Up</span>
                <span className="text-lg font-semibold text-white">{dueIn30Days}</span>
              </div>
            </div>
          </div>

          {/* Demo Toggle */}
          <button 
            onClick={() => setIsPro(false)}
            className="w-full mt-4 py-2 text-sm text-gray-500"
          >
            View locked version
          </button>
        </>
      )}
    </div>
  );
}