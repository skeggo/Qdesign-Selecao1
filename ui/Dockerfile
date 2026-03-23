# ── Stage 1: install dependencies ────────────────────────────────────────────
FROM node:20-alpine AS deps
WORKDIR /app

RUN npm install -g pnpm
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --no-frozen-lockfile

# ── Stage 2: build Next.js ───────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app

RUN npm install -g pnpm
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# NEXT_PUBLIC_* vars are baked into the build — pass via --build-arg
ARG NEXT_PUBLIC_API_URL=http://localhost:3001/api
ARG NEXT_PUBLIC_SOCKET_URL=http://localhost:3002
ARG NEXT_PUBLIC_APP_URL=http://localhost:3000

ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_SOCKET_URL=$NEXT_PUBLIC_SOCKET_URL
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL

RUN pnpm build

# ── Stage 3: production runner (Next.js + socket server) ─────────────────────
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Copy built Next.js output
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public* ./public/
COPY --from=builder /app/package.json ./package.json

# Copy all node_modules (tsx + concurrently needed at runtime for socket server)
COPY --from=deps /app/node_modules ./node_modules

# Copy the standalone socket server source
COPY --from=builder /app/server ./server

# Next.js on 3000, socket server on 3002
EXPOSE 3000 3002

# Run both processes in parallel
CMD ["node_modules/.bin/concurrently", \
     "--names", "next,socket", \
     "node_modules/.bin/next start", \
     "node_modules/.bin/tsx server/socket.ts"]
