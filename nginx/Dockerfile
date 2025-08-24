# Usar imagem oficial do Nginx
FROM nginx:alpine

# Instalar bash e base64 (vem por padrão no alpine)
RUN apk add --no-cache bash coreutils

# Criar diretório para certificados
RUN mkdir -p /etc/nginx/certs

# Copiar arquivos Base64 para dentro da imagem
COPY certs/cc  /etc/nginx/certs/cc
COPY certs/scr /etc/nginx/certs/scr
COPY certs/scs /etc/nginx/certs/scs

# Copiar configuração customizada do Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar entrypoint que decodifica os certificados
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expor porta HTTPS
EXPOSE 443

# Rodar o entrypoint
ENTRYPOINT ["/entrypoint.sh"]
