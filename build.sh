yarn run build
cp 404.html 50x.html dist
cp src/assets/50x.png dist/static/img/50x.png
cp src/assets/404.png dist/static/img/404.png
docker build -q -t ht-hk.tencentcloudcr.com/public/xlog-decoder-web:latest .
docker push ht-hk.tencentcloudcr.com/public/xlog-decoder-web:latest
