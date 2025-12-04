# Frontend Dockerfile
# Use Node.js LTS version
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy all frontend files
COPY . .

# Expose port 3000
EXPOSE 3000

# Start React development server
CMD ["npm", "start"]