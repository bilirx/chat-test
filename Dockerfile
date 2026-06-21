FROM php:8.2-cli-alpine
COPY src/ /usr/src/guvenli-app
WORKDIR /usr/src/guvenli-app
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8080}"]
