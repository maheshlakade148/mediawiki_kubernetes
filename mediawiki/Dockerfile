FROM centos:7
MAINTAINER maheshlakade148@gmail.com
RUN yum install epel-release -y && yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y && yum-config-manager --enable remi-php70 -y  && yum install httpd php php-mysql php-gd php-xml php-mbstring wget -y
ENV DocumentRoot /var/www/mediawiki
COPY httpd.conf /etc/httpd/conf/httpd.conf
RUN wget https://releases.wikimedia.org/mediawiki/1.30/mediawiki-core-1.30.0.tar.gz && tar -zxf mediawiki-core-1.30.0.tar.gz -C /var/www 
RUN ln -s /var/www/mediawiki-1.30.0 /var/www/mediawiki && chown -R apache:apache /var/www/mediawiki 
ENV MYSQL_SERVER="afb2eb76cfd4c11e8b654023401bc5a3-176976868.us-west-2.elb.amazonaws.com" 
ENV MYSQL_PASS="root@test123"
ENV MYSQL_DB="wikidatabase"
ENV MYSQL_USER="wiki"
ENV APP_USER="admin"
ENV APP_PASSWORD="root@test123" 
EXPOSE 80
ENTRYPOINT ["/usr/sbin/httpd","-D","FOREGROUND"]
