#
# iDempiere-KSYS Dockerfile of Postgresql
#
# https://github.com/longnan/ksys-idempiere-docker-pgsql
#

FROM phusion/baseimage:0.9.19
MAINTAINER Ken Longnan <ken.longnan@gmail.com>

### Make default locale
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

### Setup proxy if needed
#ENV http_proxy http://10.0.0.12:8087/
#ENV https_proxy http://10.0.0.12:8087/
#RUN export http_proxy=$http_proxy
#RUN export https_proxy=$https_proxy

### Setup fast apt in China
RUN echo "deb http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse \n" \
		 "deb http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse \n" \
	     "deb http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse \n" \
		 "deb http://mirrors.163.com/ubuntu/ xenial-proposed main restricted universe multiverse \n" \
         "deb http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ xenial-proposed main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse \n" > /etc/apt/sources.list		 

  
### Install PG from Postgresql official repository
#RUN apt-get update && \
#		DEBIAN_FRONTEND=noninteractive \
#		apt-get install -y wget
#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
#		apt-key add -		
#ENV PG_MAJOR 9.4
#RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
#		apt-get update && \
#		DEBIAN_FRONTEND=noninteractive \
#		apt-get install -y --force-yes postgresql-$PG_MAJOR postgresql-contrib-$PG_MAJOR && \
#		/etc/init.d/postgresql stop
		 
### Install PG from ubuntu default repository		
ENV PG_MAJOR 9.4 
RUN apt-get update && \
		DEBIAN_FRONTEND=noninteractive \
		apt-get install -y --force-yes postgresql-$PG_MAJOR postgresql-contrib-$PG_MAJOR && \
		/etc/init.d/postgresql stop

### Configure the database
RUN sed -i -e"s/data_directory =.*$/data_directory = '\/data'/" /etc/postgresql/$PG_MAJOR/main/postgresql.conf
# Allow connections from anywhere.
RUN sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" /etc/postgresql/$PG_MAJOR/main/postgresql.conf
RUN echo "host    all    all    0.0.0.0/0    md5" >> /etc/postgresql/$PG_MAJOR/main/pg_hba.conf

### Install other tools.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen inotify-tools

### Copy and setup iDempiere Database Package
RUN mkdir /opt/idempiere-ksys/
ADD ksys /opt/idempiere-ksys/ksys
ENV IDEMPIERE_HOME /opt/idempiere-ksys/ksys
RUN mv /opt/idempiere-ksys/ksys/myEnvironment.sh /opt/idempiere-ksys/ksys/utils;
RUN chmod 755 /opt/idempiere-ksys/ksys/utils/*.sh;
RUN chmod 755 /opt/idempiere-ksys/ksys/utils/postgresql/*.sh;

### Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### Copy scripts
ADD scripts /scripts
RUN chmod +x /scripts/start.sh
RUN touch /firstrun

### Add daemon to be run by runit.
RUN mkdir /etc/service/postgresql
RUN ln -s /scripts/start.sh /etc/service/postgresql/run

### Correct the Error: could not open temporary statistics file "/var/run/postgresql/$PG_MAJOR-main.pg_stat_tmp/global.tmp": No such file or directory
RUN mkdir -p /var/run/postgresql/$PG_MAJOR-main.pg_stat_tmp
RUN chown postgres.postgres /var/run/postgresql/$PG_MAJOR-main.pg_stat_tmp -R

EXPOSE 5432

### Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

