FROM ubuntu/apache2:2.4-20.04_beta
RUN apt update -y \
    && apt-get install -y iputils-ping \
    && apt-get install -y net-tools\
    && apt-get install jq -y

#copy files into html directory 
COPY web/* /var/www/html/

ENTRYPOINT ["apachectl", "-D", "FOREGROUND"]


# FROM amazonlinux:latest
# RUN apt-get update \
#     && yum install nginx -y \
#     && apt-get install -y iputils-ping \
#     && apt-get install -y net-tools\
#     && apt-get install jq -y
    
# # copy files into nginx html directory  
# COPY web/* /usr/share/nginx/html 

# EXPOSE 80
# ENTRYPOINT ["nginx", "-g", "daemon off;"]