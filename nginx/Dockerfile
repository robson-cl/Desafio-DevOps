# Use imagem oficial do Nginx
FROM nginx:alpine

# Instalar AWS CLI (necessário para pegar parâmetros)
RUN apk add --no-cache bash curl jq python3 py3-pip && \
    pip3 install --break-system-packages awscli
    
# Copia arquivo de configuração
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expõe porta HTTPS
EXPOSE 443

# Chamar entrypoint
ENTRYPOINT ["/entrypoint.sh"]
