#!/bin/sh
set -e

# Criar diretório de certificados caso não exista
mkdir -p /etc/nginx/certs

# Decodificar os certificados Base64
base64 -d /etc/nginx/certs/scr  > /etc/nginx/certs/server.crt
base64 -d /etc/nginx/certs/scs  > /etc/nginx/certs/server.key
base64 -d /etc/nginx/certs/cc   > /etc/nginx/certs/ca.crt

# Opcional: remover arquivos Base64 decodificados
rm /etc/nginx/certs/cc /etc/nginx/certs/scr /etc/nginx/certs/scs

# Rodar Nginx em foreground
exec nginx -g "daemon off;"
