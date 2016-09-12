USER=${USER:-postgres}
PASS=${PASS:-$(pwgen -s -1 16)}
# Default DB Version
APPDB_VERSION_TAG=3.1.0.20151031

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
  # Init Database $APPDB_VERSION_TAG
  if [[ -e  /data/tag:$APPDB_VERSION_TAG ]]; then
	   echo "Tag : $APPDB_VERSION_TAG"
  else
	   echo "Initializing Database"

     echo "1. Creating the superuser: $USER"
	setuser postgres psql -q <<-EOF
	    DROP ROLE IF EXISTS $USER;
	    CREATE ROLE $USER WITH ENCRYPTED PASSWORD '$PASS';
	    ALTER USER $USER WITH ENCRYPTED PASSWORD '$PASS';
	    ALTER ROLE $USER WITH SUPERUSER;
	    ALTER ROLE $USER WITH LOGIN;
	EOF

      echo "2. Import Seed Database"
	    cd ${IDEMPIERE_HOME}/utils
      ./RUN_ImportIdempiere.sh -y --force-yes

	    echo "3. Run Init SQL Migration"
	    export APPDB_VERSION_TAG
      cd ${IDEMPIERE_HOME}/utils
      ./RUN_SQLMigration.sh -y --force-yes

	    echo "4. Tag : $APPDB_VERSION_TAG"
	    touch /data/tag:$APPDB_VERSION_TAG
	    echo "Done. ($APPDB_VERSION_TAG)"
  fi

  # Setup migration DB version
  APPDB_VERSION_TAG=3.1.0.20160730
  # Migrate to $APPDB_VERSION_TAG
  if [[ -e /data/tag:$APPDB_VERSION_TAG ]]; then
	   echo "Tag : $APPDB_VERSION_TAG"
  else
	   echo "Migrate to $APPDB_VERSION_TAG"

	   echo "1. Run SQL Migration"
	   export APPDB_VERSION_TAG
     cd ${IDEMPIERE_HOME}/utils
     ./RUN_SQLMigration.sh -y --force-yes

	   echo "2. Tag : $APPDB_VERSION_TAG"
	   touch /data/tag:$APPDB_VERSION_TAG
	   echo "Done. ($APPDB_VERSION_TAG)"
  fi

  rm /firstrun
}
