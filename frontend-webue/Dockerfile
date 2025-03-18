FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Set environment variables
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=${REACT_APP_API_URL}
ENV PUBLIC_URL=""

# Build the application if needed (uncomment for production)
RUN npm run build

# # Stage 2: Serve the application
# FROM nginx:alpine

# # Copy build artifacts from stage 1
# COPY --from=build /app/build /usr/share/nginx/html

# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 3000
EXPOSE 3000

# Command to run the app in development mode
CMD ["npm", "start"]
