# Usar imagem oficial do Nginx
FROM nginx:alpine

# Criar diretório para os certificados
RUN mkdir -p /etc/nginx/certs

# Copiar certificados para dentro da imagem
COPY certs/server.crt /etc/nginx/certs/server.crt
COPY certs/server.key /etc/nginx/certs/server.key
COPY certs/ca.crt     /etc/nginx/certs/ca.crt

# Copiar configuração customizada do Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Expor porta HTTPS
EXPOSE 443

# Rodar Nginx em foreground
CMD ["nginx", "-g", "daemon off;"]
