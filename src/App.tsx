import { useState } from 'react'
import './index.css'

function App() {
  const [count, setCount] = useState(0)
  
  const environment = import.meta.env.VITE_ENVIRONMENT || 'unknown'
  
  // Determine environment colors and badges
  const getEnvironmentStyle = (env: string) => {
    switch(env.toLowerCase()) {
      case 'production':
        return { bg: 'bg-red-100', text: 'text-red-800', badge: 'bg-red-500', badgeText: 'text-white' }
      case 'staging':
        return { bg: 'bg-yellow-100', text: 'text-yellow-800', badge: 'bg-yellow-500', badgeText: 'text-white' }
      case 'development':
        return { bg: 'bg-green-100', text: 'text-green-800', badge: 'bg-green-500', badgeText: 'text-white' }
      default:
        return { bg: 'bg-gray-100', text: 'text-gray-800', badge: 'bg-gray-500', badgeText: 'text-white' }
    }
  }
  
  const envStyle = getEnvironmentStyle(environment)

  return (
    <div className={`min-h-screen bg-gradient-to-br ${envStyle.bg} to-indigo-100`}>
      <nav className="bg-white shadow-md">
        <div className="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-indigo-600">React + Vite + Tailwind</h1>
          <div className={`${envStyle.badge} ${envStyle.badgeText} px-4 py-2 rounded-full font-bold text-sm uppercase tracking-wide`}>
            🚀 {environment}
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 py-16">
        {/* Environment Information Card */}
        <div className="mb-8 bg-white rounded-lg shadow-lg p-8 border-2 border-indigo-200">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-bold text-gray-800">Environment Info</h2>
            <span className={`${envStyle.badge} ${envStyle.badgeText} px-3 py-1 rounded font-bold`}>
              {environment.toUpperCase()}
            </span>
          </div>
          <div className="grid md:grid-cols-2 gap-4 text-gray-700">
            <div className="bg-gray-50 p-4 rounded">
              <p className="text-sm text-gray-500 font-semibold mb-1">Environment</p>
              <p className="text-lg font-mono">{environment}</p>
            </div>
            <div className="bg-gray-50 p-4 rounded">
              <p className="text-sm text-gray-500 font-semibold mb-1">Backend URL</p>
              <p className="text-lg font-mono break-all">{import.meta.env.VITE_BACKEND_URL}</p>
            </div>
          </div>
        </div>

        <div className="grid md:grid-cols-2 gap-8">
          <div className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-4">Welcome</h2>
            <p className="text-gray-600 mb-6">
              This is a React applicationss built with Vite, TypeScript, and Tailwind CSS deployed to {environment}.
            </p>
            <button
              onClick={() => setCount(count + 1)}
              className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 px-4 rounded transition"
            >
              Count is {count}
            </button>
          </div>

          <div className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-4">Features</h2>
            <ul className="space-y-3 text-gray-600">
              <li className="flex items-center">
                <span className="text-indigo-600 mr-2">✓</span> React 19
              </li>
              <li className="flex items-center">
                <span className="text-indigo-600 mr-2">✓</span> Vite
              </li>
              <li className="flex items-center">
                <span className="text-indigo-600 mr-2">✓</span> TypeScript
              </li>
              <li className="flex items-center">
                <span className="text-indigo-600 mr-2">✓</span> Tailwind CSS
              </li>
            </ul>
          </div>
        </div>
      </main>
    </div>
  )
}

export default App
