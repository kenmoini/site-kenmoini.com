FROM nginx:alpine

COPY custom_errors.conf /etc/nginx/conf.d/custom_errors.conf

COPY public/ /usr/share/nginx/html/
