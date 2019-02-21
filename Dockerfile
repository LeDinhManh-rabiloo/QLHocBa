#========================
# Build backend source
#========================
FROM composer as vendor

WORKDIR /var/www/html

COPY . /var/www/html

RUN composer install  \
    --ignore-platform-reqs \
    --no-dev \
    --no-interaction \
    --no-progress \
    --no-suggest \
    --prefer-dist

#========================
# Build frontend assets
#========================
FROM node as frontend

RUN mkdir -p /var/www/html/public

COPY package.json package-lock.json webpack.mix.js /var/www/html
COPY resources /var/www/html/resources
WORKDIR /var/www/html

RUN npm install
RUN npm run production

#========================
# Build app image
#========================
FROM oanhnn/php:7.2-laravel

COPY . /var/www/html
COPY --from=vendor /var/www/html /var/www/html
COPY --from=frontend /var/www/html/public /var/www/html/public

RUN chown -R www-data:www-data /var/www/html
