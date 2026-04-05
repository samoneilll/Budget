import { NavLink, Outlet } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import TransactionStatusWidget from './TransactionStatusWidget'

const navItems = [
  { to: '/',             label: 'Dashboard',    end: true },
  { to: '/transactions', label: 'Transactions' },
  { to: '/budget',       label: 'Budget' },
  { to: '/savings',      label: 'Savings' },
  { to: '/mortgage',     label: 'Mortgage' },
  { to: '/flow',         label: 'Flow' },
]

export default function Layout() {
  const { theme, isDark, toggle } = useTheme()

  return (
    <div style={{ display: 'flex', height: '100vh', fontFamily: 'sans-serif', background: theme.bg, color: theme.text }}>
      <nav style={{ width: 200, padding: '1.5rem 1rem', borderRight: `1px solid ${theme.border}`, background: theme.surface, display: 'flex', flexDirection: 'column', flexShrink: 0, overflow: 'hidden' }}>
        <h2 style={{ margin: '0 0 1.5rem', fontSize: '1.1rem', color: theme.text }}>Budget</h2>
        {navItems.map(({ to, label, end }) => (
          <NavLink
            key={to}
            to={to}
            end={end}
            style={({ isActive }) => ({
              display: 'block',
              padding: '0.5rem 0.75rem',
              marginBottom: '0.25rem',
              borderRadius: 6,
              textDecoration: 'none',
              color: isActive ? theme.text : theme.textMuted,
              fontWeight: isActive ? 600 : 400,
              background: isActive ? theme.border : 'transparent',
            })}
          >
            {label}
          </NavLink>
        ))}
        <div style={{ marginTop: 'auto' }}>
          <TransactionStatusWidget />
        </div>
        <div style={{ paddingTop: '1rem', borderTop: `1px solid ${theme.border}` }}>
          <button
            onClick={toggle}
            style={{
              width: '100%',
              padding: '0.5rem 0.75rem',
              borderRadius: 6,
              border: `1px solid ${theme.border}`,
              background: 'transparent',
              color: theme.textMuted,
              cursor: 'pointer',
              fontSize: '0.85rem',
              textAlign: 'left',
            }}
          >
            {isDark ? '☀ Light mode' : '☾ Dark mode'}
          </button>
        </div>
      </nav>
      <main style={{ flex: 1, padding: '2rem', background: theme.bg, overflowY: 'auto' }}>
        <Outlet />
      </main>
    </div>
  )
}
