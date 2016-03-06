USER=${USER:-postgres}
PASS=${PASS:-$(pwgen -s -1 16)}

pre_start_action() {
  # Echo out info to later obtain by running `docker logs container_name`
  echo "POSTGRES_USER=$USER"
  echo "POSTGRES_PASS=$PASS"
  echo "POSTGRES_DATA_DIR=$DATA_DIR"
  if [ $(env | grep DB) ]; then echo "POSTGRES_DATABASE=$DB";fi

  # test if DATA_DIR has content
  if [[ ! "$(ls -A $DATA_DIR)" ]]; then
      echo "Initializing PostgreSQL at $DATA_DIR"

      # Copy the data that we generated within the container to the empty DATA_DIR.
      cp -R /var/lib/postgresql/$PG_MAJOR/main/* $DATA_DIR	  
  fi

  # Ensure postgres owns the DATA_DIR
  chown -R postgres $DATA_DIR
  # Ensure we have the right permissions set on the DATA_DIR
  chmod -R 700 $DATA_DIR
}

post_start_action() {
  # Init KSYS-iDempiere Database 3.1.20151031
  if [[ -e  /data/ksys-docker-idempiere-pgsql:3.1.20151031 ]]; then
	echo "Tag : ksys-docker-idempiere-pgsql:3.1.20151031"
  else
	echo "Initializing KSYS-iDempiere Database 3.1"
	
    echo "1. Creating the superuser: $USER"
	setuser postgres psql -q <<-EOF
	  DROP ROLE IF EXISTS $USER;
	  CREATE ROLE $USER WITH ENCRYPTED PASSWORD '$PASS';
	  ALTER USER $USER WITH ENCRYPTED PASSWORD '$PASS';
	  ALTER ROLE $USER WITH SUPERUSER;
	  ALTER ROLE $USER WITH LOGIN;
	EOF
	
	echo "2. Import KSYS-iDempiere Seed Database 3.1"
	cd /opt/idempiere-ksys/ksys/utils
    ./RUN_ImportIdempiere.sh -y --force-yes
	
	echo "3. Tag : ksys-docker-idempiere-pgsql:3.1.20151031"
	touch /data/ksys-docker-idempiere-pgsql:3.1.20151031
	echo "Done."		
  fi

  rm /firstrun
}
