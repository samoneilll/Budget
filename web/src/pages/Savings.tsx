import { useEffect, useState } from 'react'
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'
import { api } from '../api/client'

interface SavingsAccount {
  id: number
  name: string
  fortnightly_contribution_target: number | null
}

interface Snapshot {
  date: string
  balance: number
}

export default function Savings() {
  const [accounts, setAccounts] = useState<SavingsAccount[]>([])
  const [snapshots, setSnapshots] = useState<Record<number, Snapshot[]>>({})
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get<SavingsAccount[]>('/savings_accounts').then(async accs => {
      setAccounts(accs)
      const snapshotMap: Record<number, Snapshot[]> = {}
      await Promise.all(
        accs.map(async acc => {
          const data = await api.get<Snapshot[]>(`/savings_accounts/${acc.id}/savings_snapshots`)
          snapshotMap[acc.id] = data
        })
      )
      setSnapshots(snapshotMap)
    }).finally(() => setLoading(false))
  }, [])

  if (loading) return <p>Loading…</p>

  return (
    <div>
      <h1 style={{ margin: '0 0 1.5rem' }}>Savings</h1>
      {accounts.map(acc => (
        <div key={acc.id} style={{ marginBottom: '2.5rem' }}>
          <h2 style={{ fontSize: '1rem', margin: '0 0 0.75rem' }}>
            {acc.name}
            {acc.fortnightly_contribution_target != null && (
              <span style={{ fontWeight: 400, color: '#6b7280', marginLeft: 8 }}>
                target: ${Number(acc.fortnightly_contribution_target).toFixed(2)} / fortnight
              </span>
            )}
          </h2>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={snapshots[acc.id] ?? []} margin={{ top: 4, right: 16, left: 0, bottom: 4 }}>
              <XAxis dataKey="date" tick={{ fontSize: 11 }} />
              <YAxis tickFormatter={v => `$${v}`} />
              <Tooltip formatter={(v: number) => `$${v.toFixed(2)}`} />
              <Line type="monotone" dataKey="balance" stroke="#3b82f6" dot={false} strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      ))}
      {accounts.length === 0 && <p style={{ color: '#6b7280' }}>No savings accounts configured yet.</p>}
    </div>
  )
}
