#!/bin/sh
sed -i "s|ENVIRONMENT_PLACEHOLDER|${ENVIRONMENT}|g" /usr/share/nginx/html/index.html
nginx -g "daemon off;"
