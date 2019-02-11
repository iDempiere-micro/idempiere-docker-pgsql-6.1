#!/bin/bash
zcat idempiere-docker-pgsql-6.2.0.latest.tar.gz | docker load
docker volume create --name idempiere-pgsql-datastore
docker run -d -v idempiere-pgsql-datastore:/data -p 5433:5432 -e PASS="postgres" idempiere/idempiere-docker-pgsql:6.2.0.latest
