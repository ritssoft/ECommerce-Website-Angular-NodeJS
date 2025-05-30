# Dockerfile for Angular frontend
FROM node:18 as build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build --prod

# Serve using nginx
FROM nginx:alpine

# Copy built Angular app
COPY --from=build /app/dist/ecommerce /usr/share/nginx/html

# Copy screenshots folder from root into the served directory
COPY --from=build /app/screenshorts /usr/share/nginx/html/screenshorts

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]