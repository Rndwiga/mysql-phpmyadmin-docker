FROM ubuntu:22.04-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    which \
    bash \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

COPY install_and_run_mysql.sh /install_and_run_mysql.sh

RUN chmod +x /install_and_run_mysql.sh

CMD ["/install_and_mysql.sh"]