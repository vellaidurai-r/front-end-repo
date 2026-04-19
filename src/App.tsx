import { useState } from 'react'
import './index.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <nav className="bg-white shadow-md">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold text-indigo-600">React + Vite + Tailwind</h1>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 py-16">
        <div className="grid md:grid-cols-2 gap-8">
          <div className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-4">Welcome</h2>
            <p className="text-gray-600 mb-6">
              This is a React application built with Vite, TypeScript, and Tailwind CSS.
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
