#!/bin/sh
set -e

# Diretório para os certificados
mkdir -p /etc/nginx/certs

# Buscar certificados do Parameter Store via AWS CLI
# Atenção: as variáveis de ambiente AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY e AWS_REGION devem estar definidas no ECS task definition

aws ssm get-parameter --name "/nginx-proxy/server.crt" --with-decryption --query Parameter.Value --output text > /etc/nginx/certs/server.crt
aws ssm get-parameter --name "/nginx-proxy/server.key" --with-decryption --query Parameter.Value --output text > /etc/nginx/certs/server.key
aws ssm get-parameter --name "/nginx-proxy/ca.crt" --with-decryption --query Parameter.Value --output text > /etc/nginx/certs/ca.crt

# Iniciar Nginx
exec nginx -g "daemon off;"