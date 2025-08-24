# Use imagem oficial do Nginx
FROM nginx:alpine

# Copia arquivo de configuração
COPY nginx.conf /etc/nginx/nginx.conf

# Expõe porta HTTPS
EXPOSE 443

# Comando para rodar o Nginx em foreground
CMD ["nginx", "-g", "daemon off;"]
