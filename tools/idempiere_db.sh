#!/bin/bash
gzcat idempiere-docker-pgsql-6.2.0.latest.tar.gz | docker load
docker volume create --name idempiere-pgsql-datastore
