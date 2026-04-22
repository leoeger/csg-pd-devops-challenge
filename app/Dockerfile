# app/Dockerfile
FROM --platform=linux/amd64 nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]

# Flag --platform is used to specify the target platform for the image. In this case, it is set to linux/amd64, 
# which means the image will be built for the AMD64 architecture on Linux. 
# This is important for ensuring compatibility with the host system where the container will run.
# this is key to avoid the error with ARM architecture when building on M1/M2 Macs.