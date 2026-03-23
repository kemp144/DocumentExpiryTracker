import { Link } from 'react-router';
import { ArrowLeft, Calendar, FileText, CreditCard } from 'lucide-react';
import { CategoryIcon } from '../components/CategoryIcon';
import { StatusBadge } from '../components/StatusBadge';
import { Button } from '../components/Button';
import { EmptyState } from '../components/EmptyState';

export function DesignSystemPage() {
  return (
    <div className="min-h-screen bg-[#F5F5F7] pb-12">
      {/* Header */}
      <div className="bg-white border-b border-gray-200/80 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-3">
          <div className="flex items-center gap-3">
            <Link to="/">
              <button className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center active:bg-gray-100 transition-colors">
                <ArrowLeft className="w-6 h-6 text-[#007AFF]" />
              </button>
            </Link>
            <h1 className="text-[17px] font-semibold text-gray-900">Design System</h1>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Colors */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Colors</h2>
          
          <div className="bg-white rounded-2xl p-6 border border-gray-200/80 mb-4">
            <h3 className="font-semibold text-gray-900 mb-3">Primary</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              <div>
                <div className="h-16 rounded-xl bg-[#007AFF] mb-2"></div>
                <p className="text-sm font-medium text-gray-900">iOS Blue</p>
                <p className="text-xs text-gray-500">#007AFF</p>
              </div>
              <div>
                <div className="h-16 rounded-xl bg-[#5E5CE6] mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Purple</p>
                <p className="text-xs text-gray-500">#5E5CE6</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-2xl p-6 border border-gray-200/80 mb-4">
            <h3 className="font-semibold text-gray-900 mb-3">Status Colors</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              <div>
                <div className="h-16 rounded-xl bg-[#34C759] mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Green (Active)</p>
                <p className="text-xs text-gray-500">#34C759</p>
              </div>
              <div>
                <div className="h-16 rounded-xl bg-[#FF9500] mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Orange (Due Soon)</p>
                <p className="text-xs text-gray-500">#FF9500</p>
              </div>
              <div>
                <div className="h-16 rounded-xl bg-[#FF3B30] mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Red (Expired)</p>
                <p className="text-xs text-gray-500">#FF3B30</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-2xl p-6 border border-gray-200/80">
            <h3 className="font-semibold text-gray-900 mb-3">Neutrals</h3>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
              <div>
                <div className="h-16 rounded-xl bg-gray-900 mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Gray 900</p>
              </div>
              <div>
                <div className="h-16 rounded-xl bg-gray-600 mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Gray 600</p>
              </div>
              <div>
                <div className="h-16 rounded-xl bg-gray-400 mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Gray 400</p>
              </div>
              <div>
                <div className="h-16 rounded-xl bg-gray-200 mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Gray 200</p>
              </div>
              <div>
                <div className="h-16 rounded-xl bg-[#F5F5F7] border border-gray-200 mb-2"></div>
                <p className="text-sm font-medium text-gray-900">Background</p>
              </div>
            </div>
          </div>
        </section>

        {/* Typography */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Typography</h2>
          <div className="bg-white rounded-2xl p-6 border border-gray-200/80 space-y-4">
            <div>
              <p className="text-[28px] font-bold text-gray-900 tracking-tight">Large Title</p>
              <p className="text-xs text-gray-500">28px / Bold / -0.02em</p>
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">Title</p>
              <p className="text-xs text-gray-500">24px / Bold</p>
            </div>
            <div>
              <p className="text-[17px] font-semibold text-gray-900">Headline</p>
              <p className="text-xs text-gray-500">17px / Semibold</p>
            </div>
            <div>
              <p className="text-[15px] text-gray-900">Body</p>
              <p className="text-xs text-gray-500">15px / Regular</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Callout</p>
              <p className="text-xs text-gray-500">14px / Regular</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Caption</p>
              <p className="text-xs text-gray-500">12px / Regular</p>
            </div>
          </div>
        </section>

        {/* Buttons */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Buttons</h2>
          <div className="bg-white rounded-2xl p-6 border border-gray-200/80 space-y-4">
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Primary</p>
              <Button variant="primary">Primary Button</Button>
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Secondary</p>
              <Button variant="secondary">Secondary Button</Button>
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Ghost</p>
              <Button variant="ghost">Ghost Button</Button>
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Danger</p>
              <Button variant="danger">Danger Button</Button>
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Sizes</p>
              <div className="flex flex-wrap items-center gap-2">
                <Button size="sm">Small</Button>
                <Button size="md">Medium</Button>
                <Button size="lg">Large</Button>
              </div>
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Full Width</p>
              <Button fullWidth>Full Width Button</Button>
            </div>
          </div>
        </section>

        {/* Category Icons */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Category Icons</h2>
          <div className="bg-white rounded-2xl p-6 border border-gray-200/80">
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              {(['document', 'subscription', 'contract', 'warranty', 'insurance', 'other'] as const).map(category => (
                <div key={category} className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
                  <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center">
                    <CategoryIcon category={category} size={20} className="text-gray-700" />
                  </div>
                  <span className="text-sm font-medium text-gray-900 capitalize">{category}</span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Status Badges */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Status Badges</h2>
          <div className="bg-white rounded-2xl p-6 border border-gray-200/80">
            <div className="flex flex-wrap gap-3">
              <StatusBadge status="expired" text="expired 5 days ago" />
              <StatusBadge status="due-soon" text="due in 3 days" />
              <StatusBadge status="active" text="in 2 months" />
              <StatusBadge status="expired" text="expired" size="sm" />
              <StatusBadge status="due-soon" text="soon" size="sm" />
              <StatusBadge status="active" text="active" size="sm" />
            </div>
          </div>
        </section>

        {/* Cards */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Cards</h2>
          
          <div className="mb-4">
            <p className="text-sm font-semibold text-gray-700 mb-2">Standard Card</p>
            <div className="bg-white rounded-2xl p-6 border border-gray-200/80">
              <h3 className="font-semibold text-gray-900 mb-2">Card Title</h3>
              <p className="text-[15px] text-gray-600">Card content goes here. This is a standard card with rounded corners and subtle border.</p>
            </div>
          </div>

          <div>
            <p className="text-sm font-semibold text-gray-700 mb-2">Gradient Card</p>
            <div className="bg-gradient-to-br from-[#007AFF] to-[#5E5CE6] rounded-2xl p-6 text-white">
              <h3 className="font-semibold mb-2">Gradient Card</h3>
              <p className="text-sm text-white/90">Used for highlighting important information or premium features.</p>
            </div>
          </div>
        </section>

        {/* Empty States */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Empty States</h2>
          <div className="space-y-4">
            <EmptyState
              icon={Calendar}
              title="No items yet"
              description="Add your first document, subscription, or renewal to get started."
              actionLabel="Add First Item"
              actionPath="/add"
            />
          </div>
        </section>

        {/* Form Elements */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Form Elements</h2>
          <div className="bg-white rounded-2xl p-6 border border-gray-200/80 space-y-4">
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">Text Input</label>
              <input
                type="text"
                placeholder="Enter text..."
                className="w-full px-4 py-3 bg-white border border-gray-200 rounded-xl text-[15px] placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#007AFF]/20 focus:border-[#007AFF]"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">Select</label>
              <select className="w-full px-4 py-3 bg-white border border-gray-200 rounded-xl text-[15px] focus:outline-none focus:ring-2 focus:ring-[#007AFF]/20 focus:border-[#007AFF]">
                <option>Option 1</option>
                <option>Option 2</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">Toggle</label>
              <div className="bg-white rounded-xl border border-gray-200 p-4">
                <label className="flex items-center justify-between">
                  <span className="text-[15px] font-medium text-gray-900">Enable Feature</span>
                  <input
                    type="checkbox"
                    defaultChecked
                    className="w-12 h-7 appearance-none bg-gray-200 rounded-full relative cursor-pointer transition-colors checked:bg-[#34C759] before:content-[''] before:absolute before:w-5 before:h-5 before:bg-white before:rounded-full before:top-1 before:left-1 before:transition-transform checked:before:translate-x-5"
                  />
                </label>
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">Chips / Tags</label>
              <div className="flex flex-wrap gap-2">
                <span className="px-3.5 py-2 rounded-full text-sm font-medium bg-[#007AFF] text-white">
                  Selected
                </span>
                <span className="px-3.5 py-2 rounded-full text-sm font-medium bg-white border border-gray-200 text-gray-700">
                  Unselected
                </span>
                <span className="px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-700">
                  Small Chip
                </span>
              </div>
            </div>
          </div>
        </section>

        {/* Spacing Scale */}
        <section>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Spacing Scale</h2>
          <div className="bg-white rounded-2xl p-6 border border-gray-200/80">
            <div className="space-y-3">
              {[
                { name: 'xs', value: '4px' },
                { name: 'sm', value: '8px' },
                { name: 'md', value: '12px' },
                { name: 'lg', value: '16px' },
                { name: 'xl', value: '24px' },
                { name: '2xl', value: '32px' },
                { name: '3xl', value: '48px' }
              ].map(space => (
                <div key={space.name} className="flex items-center gap-4">
                  <div className="w-20 text-sm text-gray-600">{space.name}</div>
                  <div className="w-24 text-sm text-gray-500">{space.value}</div>
                  <div className="h-6 bg-[#007AFF] rounded" style={{ width: space.value }}></div>
                </div>
              ))}
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
