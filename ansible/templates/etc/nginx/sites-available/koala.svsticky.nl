upstream app {
	server unix:/tmp/unicorn.sock fail_timeout=0;
}

server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	server_name ~^(?<subdomain>koala|intro)\..*$;
	# Note: this will not redirect svsticky.nl, see server_name docs on priority.

	ssl_certificate {{ ssl_certificate }};
	ssl_certificate_key {{ ssl_certificate_key }};

	# HSTS
	add_header Strict-Transport-Security 'max-age=31536000';

	return 301 https://$subdomain.{{ canonical_hostname }}$request_uri;
}

server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	server_name koala.{{ canonical_hostname }} intro.{{ canonical_hostname }};

	ssl_certificate {{ ssl_certificate }};
	ssl_certificate_key {{ ssl_certificate_key }};

	# HSTS is already enforced in rails

	root /var/www/koala.svsticky.nl/public;

	client_max_body_size 100M;
	keepalive_timeout 10;

	error_log /var/www/koala.svsticky.nl/log/nginx.log warn;
	access_log /var/www/koala.svsticky.nl/log/access.log;

	try_files $uri @app;

	location /api {
		add_header Access-Control-Allow-Methods 'HEAD, GET, POST, PUT, PATCH, DELETE';
		add_header Access-Control-Allow-Headers 'Origin, Content-Type, Accept, Authorization';

		# No wildcards allowed, allow all '*' or specific uri, can be multiple
		add_header Access-Control-Allow-Origin 'https://radio.svsticky.nl';
	}

	location @app {
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header Host $http_host;
		proxy_set_header X-Forwarded-Proto https;
		proxy_redirect off;
		proxy_pass http://app;
	}

	error_page 500 502 503 504 /500.html;
}
