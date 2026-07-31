FROM php:8.2-apache

# Enable Apache mod_rewrite and mod_ssl
RUN a2enmod rewrite ssl headers

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

# Add SSL virtual host configuration and enable it
COPY ssl-vhost.conf /etc/apache2/sites-available/default-ssl.conf
RUN a2ensite default-ssl

# Expose port 80 and 443
EXPOSE 80 443

CMD ["apache2-foreground"]
