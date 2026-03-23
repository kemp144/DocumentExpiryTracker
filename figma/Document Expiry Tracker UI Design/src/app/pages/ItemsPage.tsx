import { useState } from 'react';
import { Search, SlidersHorizontal, Plus, FileX } from 'lucide-react';
import { Link } from 'react-router';
import { ItemCard } from '../components/ItemCard';
import { EmptyState } from '../components/EmptyState';
import { mockItems } from '../data/mockData';

export function ItemsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  
  const categories = [
    { id: 'all', label: 'All' },
    { id: 'document', label: 'Documents' },
    { id: 'subscription', label: 'Subscriptions' },
    { id: 'insurance', label: 'Insurance' },
    { id: 'warranty', label: 'Warranties' },
    { id: 'contract', label: 'Contracts' },
  ];
  
  const hasItems = mockItems.length > 0;
  
  const filteredItems = mockItems.filter(item => {
    const matchesSearch = item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         item.provider?.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = !selectedCategory || selectedCategory === 'all' || item.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });
  
  const hasSearchOrFilter = searchQuery || (selectedCategory && selectedCategory !== 'all');

  return (
    <div className="max-w-md mx-auto px-4 pt-6 pb-8">
      {/* Header */}
      <div className="mb-4">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-[28px] font-bold text-white tracking-tight">
            Items
          </h1>
          <Link 
            to="/add"
            className="w-10 h-10 rounded-full bg-[#0A84FF] flex items-center justify-center active:bg-[#0066CC] transition-colors"
          >
            <Plus className="w-5 h-5 text-white" strokeWidth={2.5} />
          </Link>
        </div>

        {hasItems && (
          <>
            {/* Search Bar */}
            <div className="relative mb-3">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
              <input
                type="text"
                placeholder="Search items..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2.5 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
              />
            </div>

            {/* Filter Chips */}
            <div className="flex items-center gap-2 overflow-x-auto pb-2 -mx-4 px-4 scrollbar-hide">
              {categories.map(category => (
                <button
                  key={category.id}
                  onClick={() => setSelectedCategory(
                    selectedCategory === category.id ? null : category.id
                  )}
                  className={`flex-shrink-0 px-3.5 py-1.5 rounded-full text-sm font-medium transition-colors ${
                    !selectedCategory && category.id === 'all' || selectedCategory === category.id
                      ? 'bg-[#0A84FF] text-white'
                      : 'bg-white/5 text-gray-400 active:bg-white/10'
                  }`}
                >
                  {category.label}
                </button>
              ))}
            </div>
          </>
        )}
      </div>

      {/* Content */}
      {!hasItems ? (
        <div className="mt-12">
          <EmptyState
            icon={FileX}
            title="No items yet"
            description="Start tracking your documents, subscriptions, and renewals."
            actionLabel="Add First Item"
            actionPath="/add"
          />
        </div>
      ) : filteredItems.length === 0 && hasSearchOrFilter ? (
        <div className="mt-12">
          <EmptyState
            icon={Search}
            title="No results found"
            description="Try adjusting your search or filter to find what you're looking for."
          />
        </div>
      ) : (
        <>
          {/* Results Count */}
          <div className="flex items-center justify-between mb-3 mt-4">
            <p className="text-sm text-gray-400">
              {filteredItems.length} {filteredItems.length === 1 ? 'item' : 'items'}
            </p>
            <button className="flex items-center gap-1.5 text-sm text-[#0A84FF] active:opacity-70">
              <SlidersHorizontal className="w-4 h-4" />
              <span>Sort</span>
            </button>
          </div>

          {/* Items List */}
          <div className="space-y-2">
            {filteredItems.map(item => (
              <ItemCard key={item.id} item={item} />
            ))}
          </div>
        </>
      )}
    </div>
  );
}