FROM php:8.2-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install cURL extension
RUN apt-get update \
    && apt-get install -y libcurl4 libcurl4-openssl-dev \
    && docker-php-ext-install curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
        build-essential \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        locales \
        zip \
        jpegoptim optipng pngquant gifsicle \
        vim \
        unzip \
        git \
        curl \
        libzip-dev \
        libonig-dev   # Added for oniguruma support

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions (including gd and pdo_mysql)
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for Laravel application
RUN groupadd -g 1000 www \
    && useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents and set permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
