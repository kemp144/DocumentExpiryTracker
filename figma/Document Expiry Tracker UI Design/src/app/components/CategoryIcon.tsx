import { FileText, CreditCard, FileCheck, Package, Shield, MoreHorizontal } from 'lucide-react';

interface CategoryIconProps {
  category: 'document' | 'subscription' | 'contract' | 'warranty' | 'insurance' | 'other';
  size?: number;
  className?: string;
}

export function CategoryIcon({ category, size = 20, className = '' }: CategoryIconProps) {
  const getIcon = () => {
    switch (category) {
      case 'document':
        return <FileText size={size} className={className} />;
      case 'subscription':
        return <CreditCard size={size} className={className} />;
      case 'contract':
        return <FileCheck size={size} className={className} />;
      case 'warranty':
        return <Package size={size} className={className} />;
      case 'insurance':
        return <Shield size={size} className={className} />;
      case 'other':
        return <MoreHorizontal size={size} className={className} />;
      default:
        return <FileText size={size} className={className} />;
    }
  };

  return getIcon();
}
