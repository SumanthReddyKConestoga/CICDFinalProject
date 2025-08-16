FROM nginx:alpine

# minimal nginx config to proxy /api to backend container
COPY nginx.conf /etc/nginx/conf.d/default.conf

# static files (your index.html etc.)
COPY . /usr/share/nginx/html

EXPOSE 80
