upstream netdata {
  server 127.0.0.1:19999;
}

server {
  listen 443 ssl;
  listen [::]:443 ssl;

  server_name metrics.svsticky.nl metrics.dev.svsticky.nl;

  ssl_certificate      /etc/letsencrypt/live/metrics.dev.svsticky.nl/fullchain.pem;
  ssl_certificate_key  /etc/letsencrypt/live/metrics.dev.svsticky.nl/privkey.pem;

  location / {
    auth_basic "Grafieken en meer";
    auth_basic_user_file /etc/nginx/htpasswd.d/metrics.dev.svsticky.nl;

    proxy_pass http://netdata;
  }
}
