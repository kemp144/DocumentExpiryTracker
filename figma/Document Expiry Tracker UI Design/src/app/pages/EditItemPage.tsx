import { useState } from 'react';
import { useParams, useNavigate } from 'react-router';
import { X } from 'lucide-react';
import { CategoryIcon } from '../components/CategoryIcon';
import { Button } from '../components/Button';
import { mockItems } from '../data/mockData';

export function EditItemPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  
  const item = mockItems.find(i => i.id === id);
  
  const [formData, setFormData] = useState({
    title: item?.title || '',
    category: item?.category || 'document' as const,
    provider: item?.provider || '',
    dueDate: item?.dueDate ? new Date(item.dueDate).toISOString().split('T')[0] : '',
    isRecurring: item?.isRecurring || false,
    recurringInterval: item?.recurringInterval || 'monthly' as const,
    amount: item?.amount?.toString() || '',
    currency: item?.currency || 'USD',
    notes: item?.notes || '',
    owner: item?.owner || '',
  });

  const [selectedReminders, setSelectedReminders] = useState<number[]>(item?.reminders || [7]);

  const categories = [
    { id: 'document', label: 'Document' },
    { id: 'subscription', label: 'Subscription' },
    { id: 'contract', label: 'Contract' },
    { id: 'warranty', label: 'Warranty' },
    { id: 'insurance', label: 'Insurance' },
    { id: 'other', label: 'Other' },
  ] as const;

  const reminderOptions = [
    { value: 0, label: 'Same day' },
    { value: 1, label: '1 day before' },
    { value: 3, label: '3 days before' },
    { value: 7, label: '7 days before' },
    { value: 30, label: '30 days before' },
  ];

  const toggleReminder = (value: number) => {
    setSelectedReminders(prev =>
      prev.includes(value)
        ? prev.filter(v => v !== value)
        : [...prev, value]
    );
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Form updated:', formData, selectedReminders);
    navigate(`/item/${id}`);
  };

  if (!item) {
    return null;
  }

  return (
    <div className="min-h-screen bg-[#0A0A0A]">
      <div className="bg-[#1C1C1E] border-b border-white/10 sticky top-0 z-10">
        <div className="max-w-md mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            <button 
              onClick={() => navigate(-1)}
              className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center active:bg-white/10 transition-colors"
            >
              <X className="w-6 h-6 text-gray-400" />
            </button>
            <h1 className="text-[17px] font-semibold text-white">Edit Item</h1>
            <button 
              onClick={handleSubmit}
              className="px-4 py-2 text-[#0A84FF] font-semibold text-[15px] active:opacity-70"
            >
              Save
            </button>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="max-w-md mx-auto px-4 py-6 pb-8">
        <div className="mb-6">
          <label className="block text-sm font-semibold text-white mb-3">
            Category
          </label>
          <div className="grid grid-cols-3 gap-2">
            {categories.map(category => (
              <button
                key={category.id}
                type="button"
                onClick={() => setFormData({ ...formData, category: category.id })}
                className={`p-3 rounded-xl border-2 transition-all ${
                  formData.category === category.id
                    ? 'border-[#0A84FF] bg-[#0A84FF]/10'
                    : 'border-white/10 bg-[#1C1C1E] active:bg-[#2C2C2E]'
                }`}
              >
                <div className="flex flex-col items-center gap-1.5">
                  <CategoryIcon category={category.id} size={24} className="text-gray-400" />
                  <span className="text-xs font-medium text-white">{category.label}</span>
                </div>
              </button>
            ))}
          </div>
        </div>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-white mb-2">Title</label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-4 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-white mb-2">Provider / Company</label>
          <input
            type="text"
            value={formData.provider}
            onChange={(e) => setFormData({ ...formData, provider: e.target.value })}
            placeholder="Optional"
            className="w-full px-4 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-white mb-2">Due Date</label>
          <input
            type="date"
            value={formData.dueDate}
            onChange={(e) => setFormData({ ...formData, dueDate: e.target.value })}
            className="w-full px-4 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
          />
        </div>

        <div className="mb-4">
          <div className="bg-[#1C1C1E] rounded-xl border border-white/10 p-4">
            <label className="flex items-center justify-between">
              <span className="text-[15px] font-medium text-white">Recurring</span>
              <input
                type="checkbox"
                checked={formData.isRecurring}
                onChange={(e) => setFormData({ ...formData, isRecurring: e.target.checked })}
                className="w-12 h-7 appearance-none bg-white/10 rounded-full relative cursor-pointer transition-colors checked:bg-[#30D158] before:content-[''] before:absolute before:w-5 before:h-5 before:bg-white before:rounded-full before:top-1 before:left-1 before:transition-transform checked:before:translate-x-5"
              />
            </label>
          </div>
        </div>

        {formData.isRecurring && (
          <div className="mb-4">
            <label className="block text-sm font-semibold text-white mb-2">Interval</label>
            <select
              value={formData.recurringInterval}
              onChange={(e) => setFormData({ ...formData, recurringInterval: e.target.value as any })}
              className="w-full px-4 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
            >
              <option value="monthly">Monthly</option>
              <option value="quarterly">Quarterly</option>
              <option value="yearly">Yearly</option>
            </select>
          </div>
        )}

        <div className="mb-4">
          <label className="block text-sm font-semibold text-white mb-2">Amount</label>
          <div className="flex gap-2">
            <select
              value={formData.currency}
              onChange={(e) => setFormData({ ...formData, currency: e.target.value })}
              className="w-24 px-3 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
            >
              <option value="USD">USD</option>
              <option value="EUR">EUR</option>
              <option value="GBP">GBP</option>
            </select>
            <input
              type="number"
              step="0.01"
              value={formData.amount}
              onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
              placeholder="0.00"
              className="flex-1 px-4 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
            />
          </div>
        </div>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-white mb-2">Owner / Person</label>
          <input
            type="text"
            value={formData.owner}
            onChange={(e) => setFormData({ ...formData, owner: e.target.value })}
            placeholder="Optional"
            className="w-full px-4 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF]"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-semibold text-white mb-3">Reminders</label>
          <div className="flex flex-wrap gap-2">
            {reminderOptions.map(option => (
              <button
                key={option.value}
                type="button"
                onClick={() => toggleReminder(option.value)}
                className={`px-3.5 py-2 rounded-full text-sm font-medium transition-colors ${
                  selectedReminders.includes(option.value)
                    ? 'bg-[#0A84FF] text-white'
                    : 'bg-[#1C1C1E] border border-white/10 text-gray-400 active:bg-[#2C2C2E]'
                }`}
              >
                {option.label}
              </button>
            ))}
          </div>
        </div>

        <div className="mb-6">
          <label className="block text-sm font-semibold text-white mb-2">Notes</label>
          <textarea
            value={formData.notes}
            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
            placeholder="Add any additional notes..."
            rows={4}
            className="w-full px-4 py-3 bg-[#1C1C1E] border border-white/10 rounded-xl text-[15px] text-white placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-[#0A84FF]/30 focus:border-[#0A84FF] resize-none"
          />
        </div>

        <Button type="submit" size="lg" fullWidth>
          Save Changes
        </Button>
      </form>
    </div>
  );
}