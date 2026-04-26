# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Build arguments for environment-specific builds
ARG VITE_ENVIRONMENT=development
ARG VITE_BACKEND_URL=http://localhost:3000

# Set environment variables for build
ENV VITE_ENVIRONMENT=$VITE_ENVIRONMENT
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Build the application with environment variables
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Install a simple HTTP server to serve static files
RUN npm install -g serve

# Copy built artifacts from builder
COPY --from=builder /app/dist ./dist

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start the application
CMD ["serve", "-s", "dist", "-l", "3000"]
