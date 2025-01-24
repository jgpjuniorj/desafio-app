FROM amazonlinux:latest

# Install dependencies
RUN yum update -y && \
    yum install -y httpd && \
    yum search wget && \
    yum install wget -y && \
    yum install unzip -y

# change directory
RUN cd /var/www/html

# download webfiles
RUN wget https://github.com/7hundredtech/E-Commerce/raw/main/E-Commerce.zip

# unzip folder
RUN unzip E-Commerce.zip

# copy files into html directory
RUN cp -r furni-1.0.0/* /var/www/html/

# remove unwanted folder
RUN rm -rf furni-1.0.0 E-Commerce.zip

# exposes port 80 on the container
EXPOSE 80

# set the default application that will start when the container start
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]