import { useEffect, useState } from 'react'
import { api } from '../api/client'

interface BudgetCategory {
  id: number
  name: string
  fortnightly_amount: number
  description: string | null
}

export default function Budget() {
  const [categories, setCategories] = useState<BudgetCategory[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get<BudgetCategory[]>('/budget_categories')
      .then(setCategories)
      .finally(() => setLoading(false))
  }, [])

  const totalFortnightly = categories.reduce((sum, c) => sum + Number(c.fortnightly_amount), 0)

  if (loading) return <p>Loading…</p>

  return (
    <div>
      <h1 style={{ margin: '0 0 1.5rem' }}>Budget Categories</h1>
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.9rem' }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #e5e7eb', textAlign: 'left' }}>
            <th style={{ padding: '0.5rem' }}>Category</th>
            <th style={{ padding: '0.5rem' }}>Description</th>
            <th style={{ padding: '0.5rem', textAlign: 'right' }}>Fortnightly</th>
          </tr>
        </thead>
        <tbody>
          {categories.map(c => (
            <tr key={c.id} style={{ borderBottom: '1px solid #f3f4f6' }}>
              <td style={{ padding: '0.5rem', fontWeight: 500 }}>{c.name}</td>
              <td style={{ padding: '0.5rem', color: '#6b7280' }}>{c.description ?? '—'}</td>
              <td style={{ padding: '0.5rem', textAlign: 'right' }}>${Number(c.fortnightly_amount).toFixed(2)}</td>
            </tr>
          ))}
        </tbody>
        <tfoot>
          <tr style={{ borderTop: '2px solid #e5e7eb', fontWeight: 600 }}>
            <td style={{ padding: '0.5rem' }} colSpan={2}>Total</td>
            <td style={{ padding: '0.5rem', textAlign: 'right' }}>${totalFortnightly.toFixed(2)}</td>
          </tr>
        </tfoot>
      </table>
    </div>
  )
}
