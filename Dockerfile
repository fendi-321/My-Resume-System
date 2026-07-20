FROM php:8.2-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install MySQL PDO extension
RUN docker-php-ext-install pdo pdo_mysql

# Set working directory
WORKDIR /var/www/html

# Copy application code
COPY . .

# Create uploads directory with proper permissions
RUN mkdir -p assets/images && \
    chown -R www-data:www-data assets/images && \
    chmod -R 755 assets/images

# Set ServerName to suppress Apache warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

CMD ["apache2-foreground"]