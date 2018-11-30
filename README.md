# idempiere-docker-pgsql

A Dockerfile that produces a container that will run [PostgreSQL][postgresql] for iDempiere. A fork of https://bitbucket.org/longnan/idempiere-docker/src/default/idempiere-docker-pgsql/ upgraded to iDempiere 6.1.

## Image Creation

```
$ docker build --rm --force-rm -t="idempiere/idempiere-docker-pgsql:6.1.0.latest" .
```

## Image Save/Load

```
# save image to tarball
$ docker save idempiere/idempiere-docker-pgsql:6.1.0.latest | gzip > idempiere-docker-pgsql-6.1.0.latest.tar.gz

# load it back
$ gzcat idempiere-docker-pgsql-6.1.0.latest.tar.gz | docker load
```

Download prepared images from:
https://sourceforge.net/projects/idempiereksys/files/idempiere-docker-image/

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
`docker inspect idempiere-pgsql`.

### Persistant data to host file system

``` shell
$ mkdir -p /tmp/postgresql
$ docker run -d --name="idempiere-pgsql" \
             -p 5432:5432 \
             -v /tmp/postgresql:/data \
             -e PASS="$(pwgen -s -1 16)" \
             idempiere/idempiere-docker-pgsql:5.1.0.latest
$ docker logs -f idempiere-pgsql
```

### Persistant data to docker volume

``` shell
$ docker volume rm idempiere-pgsql-datastore
$ docker volume create --name idempiere-pgsql-datastore
$ docker run -d --name="idempiere-pgsql" \
             -p 5432:5432 \
             -v idempiere-pgsql-datastore:/data \
             -e PASS="postgres" \
             idempiere/idempiere-docker-pgsql:5.1.0.latest
$ docker logs -f idempiere-pgsql
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

## Update/Migration DB

ToDo:
1. Add migration DB Tag check in first_run script
2. Add new folder of SQL migration script of Postgresql
