import { useEffect, useState } from 'react'
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, ReferenceLine } from 'recharts'
import { api } from '../api/client'

interface Mortgage {
  id: number
  label: string | null
  original_principal: number
  property_value: number | null
  ps_account_id: string | null
}

interface MortgageSnapshot {
  date: string
  balance: number
}

interface LvrMilestone {
  id: number
  lvr_target: number
  label: string
  achieved_at: string | null
}

export default function MortgagePage() {
  const [mortgages, setMortgages] = useState<Mortgage[]>([])
  const [snapshots, setSnapshots] = useState<Record<number, MortgageSnapshot[]>>({})
  const [milestones, setMilestones] = useState<Record<number, LvrMilestone[]>>({})
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get<Mortgage[]>('/mortgages').then(async ms => {
      setMortgages(ms)
      const snapMap: Record<number, MortgageSnapshot[]> = {}
      const msMap: Record<number, LvrMilestone[]> = {}
      await Promise.all(
        ms.flatMap(m => [
          api.get<MortgageSnapshot[]>(`/mortgages/${m.id}/mortgage_snapshots`).then(d => { snapMap[m.id] = d }),
          api.get<LvrMilestone[]>(`/mortgages/${m.id}/lvr_milestones`).then(d => { msMap[m.id] = d }),
        ])
      )
      setSnapshots(snapMap)
      setMilestones(msMap)
    }).finally(() => setLoading(false))
  }, [])

  if (loading) return <p>Loading…</p>

  return (
    <div>
      <h1 style={{ margin: '0 0 1.5rem' }}>Mortgage</h1>
      {mortgages.map(m => {
        const snaps = snapshots[m.id] ?? []
        const ms    = milestones[m.id] ?? []
        const currentBalance = snaps[0]?.balance
        const lvr = m.property_value && currentBalance
          ? ((currentBalance / m.property_value) * 100).toFixed(1)
          : null

        // LVR over time for the chart
        const lvrData = m.property_value
          ? snaps.map(s => ({ date: s.date, lvr: Number(((s.balance / m.property_value!) * 100).toFixed(2)) }))
          : []

        return (
          <div key={m.id}>
            <h2 style={{ fontSize: '1rem', margin: '0 0 0.5rem' }}>{m.label ?? 'Mortgage'}</h2>

            <div style={{ display: 'flex', gap: '2rem', marginBottom: '1.5rem', fontSize: '0.9rem' }}>
              <div><strong>Balance</strong><br />{currentBalance != null ? `$${Number(currentBalance).toLocaleString()}` : '—'}</div>
              <div><strong>LVR</strong><br />{lvr != null ? `${lvr}%` : m.property_value == null ? 'Property value not set' : '—'}</div>
              <div><strong>Original principal</strong><br />${Number(m.original_principal).toLocaleString()}</div>
            </div>

            {lvrData.length > 0 && (
              <>
                <h3 style={{ fontSize: '0.9rem', margin: '0 0 0.5rem', color: '#555' }}>LVR over time</h3>
                <ResponsiveContainer width="100%" height={220}>
                  <LineChart data={lvrData} margin={{ top: 4, right: 16, left: 0, bottom: 4 }}>
                    <XAxis dataKey="date" tick={{ fontSize: 11 }} />
                    <YAxis tickFormatter={v => `${v}%`} domain={['auto', 'auto']} />
                    <Tooltip formatter={(v: number) => `${v}%`} />
                    {ms.map(ms => (
                      <ReferenceLine
                        key={ms.id}
                        y={ms.lvr_target * 100}
                        stroke={ms.achieved_at ? '#22c55e' : '#94a3b8'}
                        strokeDasharray="4 2"
                        label={{ value: ms.label, fontSize: 11 }}
                      />
                    ))}
                    <Line type="monotone" dataKey="lvr" stroke="#6366f1" dot={false} strokeWidth={2} />
                  </LineChart>
                </ResponsiveContainer>
              </>
            )}

            {ms.length > 0 && (
              <div style={{ marginTop: '1.5rem' }}>
                <h3 style={{ fontSize: '0.9rem', margin: '0 0 0.5rem', color: '#555' }}>LVR Milestones</h3>
                <table style={{ fontSize: '0.875rem', borderCollapse: 'collapse' }}>
                  <thead>
                    <tr style={{ borderBottom: '1px solid #e5e7eb', textAlign: 'left' }}>
                      <th style={{ padding: '0.4rem 0.75rem' }}>Label</th>
                      <th style={{ padding: '0.4rem 0.75rem' }}>Target</th>
                      <th style={{ padding: '0.4rem 0.75rem' }}>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {ms.map(m => (
                      <tr key={m.id} style={{ borderBottom: '1px solid #f3f4f6' }}>
                        <td style={{ padding: '0.4rem 0.75rem' }}>{m.label}</td>
                        <td style={{ padding: '0.4rem 0.75rem' }}>{(m.lvr_target * 100).toFixed(1)}%</td>
                        <td style={{ padding: '0.4rem 0.75rem', color: m.achieved_at ? '#16a34a' : '#6b7280' }}>
                          {m.achieved_at ? `Achieved ${m.achieved_at.slice(0, 10)}` : 'Pending'}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )
      })}
      {mortgages.length === 0 && <p style={{ color: '#6b7280' }}>No mortgage configured yet.</p>}
    </div>
  )
}
