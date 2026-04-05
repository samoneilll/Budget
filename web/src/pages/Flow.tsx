import { useEffect, useRef, useState } from 'react'
import { api } from '../api/client'
import { useTheme } from '../context/ThemeContext'

// ── Types ─────────────────────────────────────────────────────────────────────

interface Category {
  id: number
  name: string
  section: string
  fortnightly_amount: string
}

interface DashboardData {
  salaries: { sam: string; ish: string; total: string }
  categories: Category[]
}

// ── Constants ─────────────────────────────────────────────────────────────────

const SECTION_COLORS: Record<string, string> = {
  spending: '#4f8ef7',
  saving:   '#34c77b',
  outgoing: '#f5a623',
}

const SECTION_LABELS: Record<string, string> = {
  spending: 'Spending',
  saving:   'Saving',
  outgoing: 'Outgoing',
}

const NODE_W   = 18
const NODE_GAP = 5   // vertical gap between category nodes
const PAD_TOP  = 40
const PAD_BOT  = 40
const PAD_L    = 150 // space for income label
const PAD_R    = 180 // space for category labels
const SVG_W    = 860

// ── Helpers ───────────────────────────────────────────────────────────────────

const fmt = (v: number) =>
  v >= 1000 ? `$${(v / 1000).toFixed(1)}k` : `$${v.toFixed(0)}`

// ── Component ─────────────────────────────────────────────────────────────────

export default function Flow() {
  const { theme } = useTheme()
  const [data, setData] = useState<DashboardData | null>(null)
  const [hovered, setHovered] = useState<number | null>(null)
  const svgRef = useRef<SVGSVGElement>(null)

  useEffect(() => {
    api.get<DashboardData>('/dashboard').then(setData)
  }, [])

  if (!data) {
    return (
      <div style={{ color: theme.textMuted, padding: '2rem' }}>Loading…</div>
    )
  }

  const totalIncome = parseFloat(data.salaries.total)
  const cats = data.categories
    .filter(c => parseFloat(c.fortnightly_amount) > 0)
    .sort((a, b) => {
      const order = ['outgoing', 'saving', 'spending']
      return order.indexOf(a.section) - order.indexOf(b.section)
    })

  const totalAlloc = cats.reduce((s, c) => s + parseFloat(c.fortnightly_amount), 0)

  // Dynamic SVG height: at least 45px per category
  const minH = cats.length * 45 + PAD_TOP + PAD_BOT
  const SVG_H = Math.max(560, minH)

  const availH = SVG_H - PAD_TOP - PAD_BOT
  const totalGaps = (cats.length - 1) * NODE_GAP
  const scale = (availH - totalGaps) / totalAlloc // px per $

  // Income node (left)
  const incomeNodeH = totalAlloc * scale
  const incomeNodeY = PAD_TOP + (availH - incomeNodeH) / 2
  const incomeNodeX = PAD_L

  // Category nodes (right)
  const rightX = SVG_W - PAD_R - NODE_W
  let curY = PAD_TOP
  const catNodes = cats.map(cat => {
    const amount = parseFloat(cat.fortnightly_amount)
    const h = amount * scale
    const node = { cat, amount, y: curY, h }
    curY += h + NODE_GAP
    return node
  })

  // Flows: track position on income node as we draw each band
  let incomeY = incomeNodeY
  const flows = catNodes.map(node => {
    const { cat, amount, y, h } = node
    const iy1 = incomeY
    const iy2 = incomeY + h
    incomeY += h

    const x1 = incomeNodeX + NODE_W
    const x2 = rightX
    const mx  = (x1 + x2) / 2

    const d =
      `M ${x1} ${iy1}` +
      ` C ${mx} ${iy1}, ${mx} ${y}, ${x2} ${y}` +
      ` L ${x2} ${y + h}` +
      ` C ${mx} ${y + h}, ${mx} ${iy2}, ${x1} ${iy2}` +
      ` Z`

    const color = SECTION_COLORS[cat.section] ?? '#888'
    return { cat, amount, d, color, iy1, iy2, y, h }
  })

  const sections = [...new Set(cats.map(c => c.section))]

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: '1.5rem', marginBottom: '1rem' }}>
        <h1 style={{ margin: 0, fontSize: '1.4rem', color: theme.text }}>Income Flow</h1>
        <span style={{ fontSize: '0.85rem', color: theme.textMuted }}>
          fortnightly &mdash; income {fmt(totalIncome)}, allocated {fmt(totalAlloc)}
          {Math.abs(totalIncome - totalAlloc) > 1 && (
            <span style={{ color: totalIncome < totalAlloc ? '#e55' : theme.textMuted }}>
              {' '}({totalIncome > totalAlloc ? '+' : ''}{fmt(totalIncome - totalAlloc)})
            </span>
          )}
        </span>

        {/* Legend */}
        <div style={{ display: 'flex', gap: '1rem', marginLeft: 'auto' }}>
          {sections.map(s => (
            <span key={s} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: '0.8rem', color: theme.textMuted }}>
              <span style={{ width: 10, height: 10, borderRadius: 2, background: SECTION_COLORS[s] ?? '#888', display: 'inline-block' }} />
              {SECTION_LABELS[s] ?? s}
            </span>
          ))}
        </div>
      </div>

      <svg
        ref={svgRef}
        viewBox={`0 0 ${SVG_W} ${SVG_H}`}
        style={{ width: '100%', display: 'block', maxHeight: '80vh' }}
      >
        {/* Flows */}
        {flows.map(({ cat, d, color }) => (
          <path
            key={cat.id}
            d={d}
            fill={color}
            opacity={hovered === null || hovered === cat.id ? 0.35 : 0.1}
            style={{ cursor: 'pointer', transition: 'opacity 0.15s' }}
            onMouseEnter={() => setHovered(cat.id)}
            onMouseLeave={() => setHovered(null)}
          />
        ))}

        {/* Income node */}
        <rect
          x={incomeNodeX}
          y={incomeNodeY}
          width={NODE_W}
          height={incomeNodeH}
          fill={theme.accent}
          rx={3}
        />
        {/* Income label */}
        <text
          x={incomeNodeX - 10}
          y={incomeNodeY + incomeNodeH / 2 - 8}
          textAnchor="end"
          dominantBaseline="middle"
          fontSize={13}
          fontWeight={600}
          fill={theme.text}
        >
          Income
        </text>
        <text
          x={incomeNodeX - 10}
          y={incomeNodeY + incomeNodeH / 2 + 10}
          textAnchor="end"
          dominantBaseline="middle"
          fontSize={12}
          fill={theme.textMuted}
        >
          {fmt(totalIncome)}/fn
        </text>

        {/* Sam/Ish breakdown label */}
        <text
          x={incomeNodeX - 10}
          y={incomeNodeY + incomeNodeH / 2 + 28}
          textAnchor="end"
          dominantBaseline="middle"
          fontSize={10}
          fill={theme.textMuted}
        >
          Sam {fmt(parseFloat(data.salaries.sam))} · Ish {fmt(parseFloat(data.salaries.ish))}
        </text>

        {/* Category nodes */}
        {catNodes.map(({ cat, amount, y, h }) => {
          const color = SECTION_COLORS[cat.section] ?? '#888'
          const isHovered = hovered === cat.id
          const labelY = y + h / 2
          return (
            <g
              key={cat.id}
              style={{ cursor: 'pointer' }}
              onMouseEnter={() => setHovered(cat.id)}
              onMouseLeave={() => setHovered(null)}
            >
              <rect
                x={rightX}
                y={y}
                width={NODE_W}
                height={h}
                fill={color}
                opacity={hovered === null || isHovered ? 1 : 0.4}
                rx={3}
                style={{ transition: 'opacity 0.15s' }}
              />
              {/* Category name */}
              <text
                x={rightX + NODE_W + 9}
                y={h >= 22 ? labelY - (h >= 34 ? 8 : 0) : labelY}
                dominantBaseline="middle"
                fontSize={12}
                fontWeight={isHovered ? 600 : 400}
                fill={theme.text}
                style={{ transition: 'font-weight 0.1s' }}
              >
                {cat.name}
              </text>
              {/* Amount — only if node is tall enough */}
              {h >= 34 && (
                <text
                  x={rightX + NODE_W + 9}
                  y={labelY + 10}
                  dominantBaseline="middle"
                  fontSize={10}
                  fill={theme.textMuted}
                >
                  {fmt(amount)}/fn
                </text>
              )}
            </g>
          )
        })}
      </svg>
    </div>
  )
}
