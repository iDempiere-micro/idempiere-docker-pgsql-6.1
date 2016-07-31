# ksys-idempiere-docker-pgsql

A Dockerfile that produces a container that will run [PostgreSQL][postgresql] for iDempiere-KSYS.
The Postgresql part in Dockerfile was forked from https://github.com/Painted-Fox/docker-postgresql
The base image is from https://github.com/phusion/baseimage-docker

[postgresql]: http://www.postgresql.org/

## Image Creation

This example creates the image with the tag `longnan/ksys-idempiere-docker-pgsql`, but you can
change this to use your own username.

```
$ sudo docker build --rm --force-rm -t="longnan/ksys-idempiere-docker-pgsql:3.1.0.20160730" .
```

## Image Save/Load

```
# save image to tarball
$ sudo docker save longnan/ksys-idempiere-docker-pgsql:3.1.0.20160730 | gzip > ksys-idempiere-docker-pgsql-3.1.0.20160730.tar.gz

# load it back
$ sudo gzcat ksys-idempiere-docker-pgsql-3.1.0.20160730.tar.gz | docker load 
```

Download prepared images from:
https://sourceforge.net/projects/idempiereksys/files/idempiere-ksys-docker-image/

## Container Creation / Running

The PostgreSQL server is configured to store data in `/data` inside the
container.  You can map the container's `/data` volume to a volume on the host
so the data becomes independent of the running container. There is also an 
additional volume at `/var/log/postgresql` which exposes PostgreSQL's logs.

This example uses `/tmp/postgresql` to store the PostgreSQL data, but you can
modify this to your needs.

When the container runs, it creates a superuser with a random password.  You
can set the username and password for the superuser by setting the container's
environment variables.  This lets you discover the username and password of the
superuser from within a linked container or from the output of 
`docker inspect ksys-idempiere-pgsql`.

### Persistant data to host file system

``` shell
$ mkdir -p /tmp/postgresql
$ docker run -d --name="ksys-idempiere-pgsql" \
             -p 5432:5432 \
             -v /tmp/postgresql:/data \
             -e PASS="$(pwgen -s -1 16)" \
             longnan/ksys-idempiere-docker-pgsql:3.1.0.20160730
$ docker logs -f ksys-idempiere-pgsql
```

### Persistant data to docker volume

``` shell
$ docker volume create --name ksys-idempiere-pgsql-datastore
$ docker run -d --name="ksys-idempiere-pgsql" \
             -p 5432:5432 \
             -v ksys-idempiere-pgsql-datastore:/data \
             -e PASS="postgres" \
             longnan/ksys-idempiere-docker-pgsql:3.1.0.20160730
$ docker logs -f ksys-idempiere-pgsql
```

## Connecting to the Database

To connect to the PostgreSQL server, you will need to make sure you have
a client.  You can install the `postgresql-client` on your host machine by
running the following (Ubuntu 12.04LTS):

``` shell
$ sudo apt-get install postgresql-client
```

As part of the startup for PostgreSQL, the container will generate a random
password for the superuser.  To view the login in run `docker logs <container_name>` like so:

``` shell
$ docker logs postgresql
POSTGRES_USER=super
POSTGRES_PASS=b2rXEpToTRoK8PBx
POSTGRES_DATA_DIR=/data
Starting PostgreSQL...
Creating the superuser: super
Creating database: database_name
```

Then you can connect to the PostgreSQL server from the host with the following
command:

``` shell
$ psql -h localhost -p 5432 -U super template1
```

Then enter the password from the `docker logs` command when prompted.

## Linking with the Database Container

You can link a container to the database container.  You may want to do this to
keep web application processes that need to connect to the database in
a separate container.

To demonstrate this, we can spin up a new container like so:

``` shell
$ docker run -t -i --link postgresql:db ubuntu bash
```

This assumes you're already running the database container with the name
*postgresql*.  The `--link postgresql:db` will give the linked container the
alias *db* inside of the new container.

From the new container you can connect to the database by running the following
commands:

``` shell
$ apt-get install -y postgresql-client
$ psql -U "$DB_ENV_USER" \
       -h "$DB_PORT_5432_TCP_ADDR" \
       -p "$DB_PORT_5432_TCP_PORT"
```

If you ran the *postgresql* container with the flags `-e USER=<user>` and `-e
PASS=<pass>`, then the linked container should have these variables available
in its environment.  Since we aliased the database container with the name
*db*, the environment variables from the database container are copied into the
linked container with the prefix `DB_ENV_`.

## Update

1. Add version check in first_run script
2. Add new version folder of SQL migration script of Postgresql 

## TODO
