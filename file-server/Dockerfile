FROM fabiocicerchia/nginx-lua:debian-compat

RUN apt-get update && apt-get --assume-yes install jq tree

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY scripts bin
RUN chmod 777 bin/*




