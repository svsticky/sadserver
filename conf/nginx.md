# nginx op `skyblue`

Skyblue draait op dit moment nginx versie 1.6.3.

## Templates voor configuratie van sites

Er draaien verschillende sites op de server. Om consistentie aan te houden in de verschillende subdomeinen van `svsticky.nl` en andere sites, zijn hieronder templates geplaatst die op dit moment gebruikt moeten kunnen worden voor de meeste sites. 

### Template voor configuratie `example.svsticky.nl`

```
server {
        listen 80;

        server_name example.svsticky.nl;
		return 301 https://example.svsticky.nl$request_uri;
}

server {
		listen 443 ssl;
		server_name example.svsticky.nl;

        root /var/www/example.svsticky.nl;
        index index.php index.html index.htm;

        location / {
		try_files $uri $uri/ /index.php?q=$uri&$args;
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /usr/share/nginx/www;
        }

        location ~ \.php$ {
		try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/tmp/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
        }
}
```

### Template voor configuratie `example.tld`

```
server {
        listen 80;

        server_name example.tld www.example.tld example.svsticky.nl;
        return 301 https://$server_name$request_uri;
}

server {
        listen 443 ssl;
        server_name example.tld www.example.tld example.svsticky.nl;

        ssl_certificate /etc/letsencrypt/live/example.tld/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.tld/privkey.pem;

        # HSTS
		add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";
	
        root /var/www/example.committee/example.tld;
        index index.php index.html index.htm;

        if (!-e $request_filename) {
            rewrite ^/(.+)$ /index.php?url=$1 last;
            break;
        }

        include includes/php-parameters;

        location ~* \.(css|js)$ {
                expires 24h;
                add_header Pragma public;
                add_header Cache-Control "public, must-revalidate, proxy-revalidate";
        }

        location ~* \.(gif|jpe?g|png)$ {
                expires 168h;
                add_header Pragma public;
                add_header Cache-Control "public, must-revalidate, proxy-revalidate";
        }

}
```
