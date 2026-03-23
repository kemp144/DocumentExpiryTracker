export interface Item {
  id: string;
  title: string;
  category: 'document' | 'subscription' | 'contract' | 'warranty' | 'insurance' | 'other';
  provider?: string;
  dueDate: Date;
  isRecurring: boolean;
  recurringInterval?: 'monthly' | 'yearly' | 'quarterly';
  amount?: number;
  currency?: string;
  notes?: string;
  owner?: string;
  reminders?: number[]; // days before
  status?: 'active' | 'expired' | 'due-soon';
}

export const mockItems: Item[] = [
  {
    id: '1',
    title: 'Passport',
    category: 'document',
    provider: 'US Government',
    dueDate: new Date('2026-08-15'),
    isRecurring: false,
    notes: 'Main passport for international travel',
    owner: 'John',
    reminders: [30, 7, 1],
    status: 'active'
  },
  {
    id: '2',
    title: 'Netflix',
    category: 'subscription',
    provider: 'Netflix Inc.',
    dueDate: new Date('2026-04-05'),
    isRecurring: true,
    recurringInterval: 'monthly',
    amount: 15.99,
    currency: 'USD',
    reminders: [1],
    status: 'due-soon'
  },
  {
    id: '3',
    title: 'Car Insurance',
    category: 'insurance',
    provider: 'State Farm',
    dueDate: new Date('2026-06-01'),
    isRecurring: true,
    recurringInterval: 'yearly',
    amount: 1200,
    currency: 'USD',
    notes: 'Comprehensive coverage',
    reminders: [30, 7],
    status: 'active'
  },
  {
    id: '4',
    title: 'Driver License',
    category: 'document',
    provider: 'DMV',
    dueDate: new Date('2026-03-20'),
    isRecurring: false,
    notes: 'Renewal required',
    reminders: [30, 7, 1],
    status: 'expired'
  },
  {
    id: '5',
    title: 'Spotify Premium',
    category: 'subscription',
    provider: 'Spotify',
    dueDate: new Date('2026-03-28'),
    isRecurring: true,
    recurringInterval: 'monthly',
    amount: 10.99,
    currency: 'USD',
    reminders: [1],
    status: 'due-soon'
  },
  {
    id: '6',
    title: 'Laptop Warranty',
    category: 'warranty',
    provider: 'AppleCare',
    dueDate: new Date('2026-12-15'),
    isRecurring: false,
    amount: 299,
    currency: 'USD',
    notes: 'MacBook Pro 16" 2024',
    reminders: [30, 7],
    status: 'active'
  },
  {
    id: '7',
    title: 'Office Lease',
    category: 'contract',
    provider: 'WeWork',
    dueDate: new Date('2026-09-30'),
    isRecurring: true,
    recurringInterval: 'yearly',
    amount: 24000,
    currency: 'USD',
    notes: 'Annual renewal',
    reminders: [60, 30, 7],
    status: 'active'
  },
  {
    id: '8',
    title: 'Adobe Creative Cloud',
    category: 'subscription',
    provider: 'Adobe',
    dueDate: new Date('2026-03-25'),
    isRecurring: true,
    recurringInterval: 'monthly',
    amount: 54.99,
    currency: 'USD',
    reminders: [1],
    status: 'due-soon'
  }
];

export const getItemStatus = (item: Item): 'expired' | 'due-soon' | 'active' => {
  const today = new Date();
  const dueDate = new Date(item.dueDate);
  const daysUntilDue = Math.ceil((dueDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
  
  if (daysUntilDue < 0) return 'expired';
  if (daysUntilDue <= 14) return 'due-soon';
  return 'active';
};

export const getCountdownText = (dueDate: Date): string => {
  const today = new Date();
  const due = new Date(dueDate);
  const daysUntilDue = Math.ceil((due.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
  
  if (daysUntilDue < 0) {
    const daysExpired = Math.abs(daysUntilDue);
    return daysExpired === 1 ? 'expired 1 day ago' : `expired ${daysExpired} days ago`;
  }
  if (daysUntilDue === 0) return 'due today';
  if (daysUntilDue === 1) return 'due tomorrow';
  if (daysUntilDue <= 7) return `in ${daysUntilDue} days`;
  if (daysUntilDue <= 30) return `in ${daysUntilDue} days`;
  
  const months = Math.ceil(daysUntilDue / 30);
  return months === 1 ? 'in 1 month' : `in ${months} months`;
};

export const formatDate = (date: Date): string => {
  return new Intl.DateTimeFormat('en-US', { 
    month: 'short', 
    day: 'numeric', 
    year: 'numeric' 
  }).format(new Date(date));
};

export const getCategoryColor = (category: string): string => {
  const colors: Record<string, string> = {
    document: '#0066CC',
    subscription: '#5E5CE6',
    contract: '#34C759',
    warranty: '#FF9500',
    insurance: '#FF3B30',
    other: '#8E8E93'
  };
  return colors[category] || colors.other;
};
