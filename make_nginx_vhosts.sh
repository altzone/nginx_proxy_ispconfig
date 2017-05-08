#!/bin/bash

for i in `ls /etc/apache2/sites-enabled/100-*`; do
cert=""
servername=""
key=""
while read line; do
        line_array=( $line)
        [[ $line =~ ServerName   ]] && servername=${line_array[1]}
        [[ $line =~ SSLCertificateFile   ]] && cert=${line_array[1]}
        [[ $line =~ SSLCertificateKeyFile ]] && key=${line_array[1]}
done  < <(echo "`cat $i`")

if [ ! -z "$key" ]; then
echo "server {
        listen 94.23.216.90:80;
        server_name $servername;
  return 301 https://www.$servername\$request_uri;
}



server {
        listen 94.23.216.90:443;
        server_name $servername;
        ssl on;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers \"ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4\";
        ssl_prefer_server_ciphers on;
        ssl_certificate $cert;
        ssl_certificate_key $key;
        real_ip_header X-Forwarded-For;
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection \"1; mode=block\";
        proxy_hide_header X-Powered-By;
        server_tokens off;


        location / {
                proxy_pass http://ispconfig;
                proxy_set_header Host \$http_host;
                proxy_http_version 1.1;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
        }
}
" > /etc/nginx/sites-enabled/$servername.conf
else

echo "server {
        listen 94.23.216.90:80;
        server_name $servername;
        location / {
                proxy_pass http://ispconfig;
                proxy_set_header Host \$http_host;
                proxy_http_version 1.1;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
        }
}
" > /etc/nginx/sites-enabled/$servername.conf

fi
done
