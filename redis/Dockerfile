FROM redis:4.0
COPY ./redis/entrypoint.sh /usr/bin/
COPY ./redis/redis.conf /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]