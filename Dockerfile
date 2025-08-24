# 第一阶段下载源码包
FROM alpine:latest AS builder

# 源码地址
ENV URL=https://gitee.com/technical-laohu/mpay/releases/download/v1.2.4/mpay_v1.2.4.zip

RUN apk add --no-cache wget unzip && \
    wget $URL -O /tmp/mpay.zip && \
    unzip /tmp/mpay.zip -d /tmp/mpay


# 第二阶段构建镜像
FROM php:8.2-apache

RUN a2enmod rewrite && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-enable pdo_mysql

WORKDIR /var/www/html

COPY --from=builder /tmp/mpay/* /var/www/html
COPY ./.htaccess /var/www/html/public

# 配置 Apache 虚拟主机
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory "/var/www/html/public">\n\
        Options FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# 设置目录权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/public
