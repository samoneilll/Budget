import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { ThemeProvider } from './context/ThemeContext'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import Budget from './pages/Budget'
import Savings from './pages/Savings'
import Mortgage from './pages/Mortgage'
import Transactions from './pages/Transactions'
import Flow from './pages/Flow'

export default function App() {
  return (
    <ThemeProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Dashboard />} />
            <Route path="budget" element={<Budget />} />
            <Route path="savings" element={<Savings />} />
            <Route path="mortgage" element={<Mortgage />} />
            <Route path="transactions" element={<Transactions />} />
            <Route path="flow" element={<Flow />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </ThemeProvider>
  )
}
