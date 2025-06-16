# Use the official minimal NGINX image
FROM nginx:1.25-alpine

# Copy only necessary files
COPY index.html style.css script.js /usr/share/nginx/html/

# Expose the default HTTP port
EXPOSE 80

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
