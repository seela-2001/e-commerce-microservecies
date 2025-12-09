# Stage 1: Build
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY ../ .

# Stage 2: Production (Distroless)
FROM gcr.io/distroless/nodejs:16
WORKDIR /app
COPY --from=builder /app ./

# Expose port
EXPOSE 4000

# Start application
CMD ["server.js"]
