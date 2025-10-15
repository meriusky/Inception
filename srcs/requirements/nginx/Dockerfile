# 1️⃣ Base image
FROM debian:bullseye

# 2️⃣ Install NGINX + OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 3️⃣ Remove default NGINX config
RUN rm /etc/nginx/sites-enabled/default

# 4️⃣ Create directories for certificates
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# 5️⃣ Generate self-signed certificate for mehernan.42.fr
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/mehernan.key \
    -out /etc/ssl/certs/mehernan.crt \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=42School/OU=Mehernan/CN=mehernan.42.fr"

# 6️⃣ Generate DH parameters for stronger TLSv1.2
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# 7️⃣ Copy custom NGINX config
COPY nginx.conf /etc/nginx/nginx.conf

# 8️⃣ Expose HTTPS port only
EXPOSE 443

# 9️⃣ Run NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]

