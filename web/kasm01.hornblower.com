server {
    listen 80;
    server_name kasm01.hornblower.com;

    include snippets/letsencrypt.conf;
    return 301 https://kasm01.hornblower.com$request_uri;
}

server {
    listen 443 ssl http2;
    server_name kasm01.hornblower.com;

    # Allow large requests to support file uploads to sessions
    client_max_body_size 512M;

    # WebSocket Support
    proxy_set_header        Upgrade $http_upgrade;
    proxy_set_header        Connection "upgrade";

    # Host and X headers from Kasm doc example
    proxy_set_header        Host $host;
    # proxy_set_header      X-Forwarded-Host $host;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;

    # Connectivity Options
    proxy_http_version      1.1;
    # proxy_read_timeout 720s;
    # proxy_connect_timeout 720s;
    # proxy_send_timeout 720s;
    proxy_read_timeout      1800s;
    proxy_send_timeout      1800s;
    proxy_connect_timeout   1800s;
    proxy_buffering         off;

    # SSL parameters
    #
    # Lets Encrypt
    # ssl_certificate /etc/letsencrypt/live/kasm01.hornblower.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/kasm01.hornblower.com/privkey.pem;
    # ssl_trusted_certificate /etc/letsencrypt/live/kasm01.hornblower.com/chain.pem;
    # include snippets/letsencrypt.conf;

    # Okta integration
    # ssl_certificate /etc/ssl/certs/chain.pem;
    # ssl_certificate_key /etc/ssl/private/private.key;
    # ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
    #
    # Wildcard
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    include snippets/ssl.conf;

    # log files
    access_log /var/log/nginx/kasm01.hornblower.com.access.log;
    error_log /var/log/nginx/kasm01.hornblower.com.error.log;

    # Handle / requests
    location / {
       proxy_pass https://127.0.0.1:8443;
       proxy_redirect default;
    }
}
