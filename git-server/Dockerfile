FROM fabiocicerchia/nginx-lua:debian-compat

RUN apt-get update && apt-get --assume-yes install jq tree git

COPY nginx/nginx.conf /etc/nginx/nginx.conf

#RUN mkdir -p /root/.ssh && ln -s /run/secrets/user_ssh_key > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa && ssh-keyscan -t rsa bitbucket.org >> /root/.ssh/known_hosts

RUN mkdir -p /nonexistent/.ssh && ln -s /run/secrets/user_ssh_key /nonexistent/.ssh/id_rsa && \
  chown -R nginx:nginx /nonexistent/.ssh  && \
  ssh-keyscan -t rsa bitbucket.org >> /nonexistent/.ssh/known_hosts && chmod 777 /nonexistent/.ssh

COPY scripts bin
RUN chmod 777 bin/*




