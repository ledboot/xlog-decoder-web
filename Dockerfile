FROM ht-hk.tencentcloudcr.com/public/nginx:1.19.7-alpine

RUN rm -rf /etc/nginx/conf.d/default.conf

RUN rm -rf /etc/nginx/conf.d/nginx.conf

ADD nginx.conf /etc/nginx/conf.d/nginx.conf

ADD dist /app/html