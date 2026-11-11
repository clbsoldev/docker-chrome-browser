# TODO: Replace this entire image/ directory with your actual image.
#
# FROM debian:trixie-slim
#
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends <packages> \
#     && rm -rf /var/lib/apt/lists/*
#
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
#
# ENTRYPOINT ["/entrypoint.sh"]

FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
