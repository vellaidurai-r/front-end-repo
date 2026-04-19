# Frontend - React + Vite + TypeScript + Tailwind CSS

A modern frontend application built with React 19, Vite, TypeScript, and Tailwind CSS.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- npm or yarn

### Installation

```bash
npm install
```

### Development

Run the development server:

```bash
npm run dev
```

The app will be available at `http://localhost:5173`

### Build

Build for production:

```bash
npm run build
```

### Preview

Preview the production build locally:

```bash
npm run preview
```

### Lint

Check code quality:

```bash
npm run lint
```

## 📋 Tech Stack

- **React 19** - UI library
- **Vite** - Build tool and dev server
- **TypeScript** - Type-safe JavaScript
- **Tailwind CSS** - Utility-first CSS framework
- **ESLint** - Code linting
- **PostCSS** - CSS processing with Tailwind

## 📁 Project Structure

```
src/
├── App.tsx          # Main app component
├── index.css        # Global styles (Tailwind)
├── main.tsx         # Entry point
└── assets/          # Static assets

public/             # Public assets
dist/               # Build output
```

## 🎨 Tailwind CSS

Tailwind CSS is configured and ready to use. All utility classes are available:

```tsx
<div className="bg-blue-500 text-white p-4 rounded-lg">
  Styled with Tailwind CSS
</div>
```

## 🚀 Deployment

This frontend can be deployed using the CI/CD pipeline from the backend repository or as a standalone application.

## 📝 Notes

- Hot Module Replacement (HMR) is enabled for fast development
- TypeScript strict mode is enabled
- ESLint is configured for React best practices
- Tailwind CSS is optimized for production

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
