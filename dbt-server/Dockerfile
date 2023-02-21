FROM fabiocicerchia/nginx-lua:debian-compat

RUN apt-get update && apt-get --assume-yes install python3-pip jq && pip3 install dbt-snowflake dbt-mysql

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY scripts bin
RUN chmod 777 bin/*




