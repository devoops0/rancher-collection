version: '2'

services:
  zammad-backup:
    command: ["zammad-backup"]
    depends_on:
      - zammad-railsserver
    entrypoint: /usr/local/bin/backup.sh
    image: zammad/zammad-docker-compose:zammad-postgresql
    links:
      - zammad-postgresql
    restart: always
    volumes:
      - zammad-backup:/var/tmp/zammad
      - zammad-data:/opt/zammad

  zammad-elasticsearch:
    image: zammad/zammad-docker-compose:zammad-elasticsearch
    {{- if eq .Values.UPDATE_SYSCTL "true" }}
    labels:
      io.rancher.sidekicks: zammad-elasticsearch-sysctl
    {{- end}}
    restart: always
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data

  {{- if eq .Values.UPDATE_SYSCTL "true" }}
  zammad-elasticsearch-sysctl:
    labels:
        io.rancher.container.start_once: true
    network_mode: none
    image: rawmind/alpine-sysctl:0.1
    privileged: true
    environment:
        - "SYSCTL_KEY=vm.max_map_count"
        - "SYSCTL_VALUE=262144"
  {{- end}}

  zammad-init:
    command: ["zammad-init"]
    depends_on:
      - zammad-postgresql
    image: zammad/zammad-docker-compose:zammad
    labels:
      io.rancher.container.start_once: true
    links:
      - zammad-elasticsearch
      - zammad-postgresql
    restart: on-failure
    volumes:
      - zammad-data:/opt/zammad

  {{- if eq .Values.USE_LB "true" }}
  zammad-lb:
    image: rancher/lb-service-haproxy:v0.7.9
    ports:
      - ${PUBLISH_PORT}:${PUBLISH_PORT}/tcp
  {{- end}}

  zammad-memcached:
    command: ["zammad-memcached"]
    image: zammad/zammad-docker-compose:zammad-memcached
    restart: always

  zammad-nginx:
    command: ["zammad-nginx"]
    depends_on:
      - zammad-railsserver
    image: zammad/zammad-docker-compose:zammad
    links:
      - zammad-railsserver
      - zammad-websocket
    restart: always
    volumes:
      - zammad-data:/opt/zammad

  zammad-postgresql:
    image: zammad/zammad-docker-compose:zammad-postgresql
    restart: always
    volumes:
      - postgresql-data:/var/lib/postgresql/data

  zammad-railsserver:
    command: ["zammad-railsserver"]
    depends_on:
      - zammad-memcached
      - zammad-postgresql
    image: zammad/zammad-docker-compose:zammad
    links:
      - zammad-elasticsearch
      - zammad-memcached
      - zammad-postgresql
    restart: always
    volumes:
      - zammad-data:/opt/zammad

  zammad-scheduler:
    command: ["zammad-scheduler"]
    depends_on:
      - zammad-memcached
      - zammad-railsserver
    image: zammad/zammad-docker-compose:zammad
    links:
      - zammad-elasticsearch
      - zammad-memcached
      - zammad-postgresql
    restart: always
    volumes:
      - zammad-data:/opt/zammad

  zammad-websocket:
    command: ["zammad-websocket"]
    depends_on:
      - zammad-memcached
      - zammad-railsserver
    image: zammad/zammad-docker-compose:zammad
    links:
      - zammad-postgresql
      - zammad-memcached
    restart: always
    volumes:
      - zammad-data:/opt/zammad

volumes:
  elasticsearch-data:
    driver: rancher-nfs
    driver_opts:
        onRemove: retain
        exportBase: /zammad
  postgresql-data:
    driver: rancher-nfs
    driver_opts:
        onRemove: retain
        exportBase: /zammad
  zammad-backup:
    driver: rancher-nfs
    driver_opts:
        onRemove: retain
        exportBase: /zammad
  zammad-data:
    driver: rancher-nfs
    driver_opts:
        onRemove: retain
        exportBase: /zammad
