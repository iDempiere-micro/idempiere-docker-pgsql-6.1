#!/bin/sh
#

if [ $IDEMPIERE_HOME ]; then
  cd $IDEMPIERE_HOME/utils
fi
. ./myEnvironment.sh Server
echo Import Adempiere - $IDEMPIERE_HOME \($ADEMPIERE_DB_NAME\)

SUFFIX=""
SYSUSER=system
if [ $ADEMPIERE_DB_PATH = "postgresql" ]
then
    SUFFIX="_pg"
    SYSUSER=postgres
fi

run_migration() 
{
  MIGRATION_PATH=$1  

  echo Last SQL Migration folder for seed database $MIGRATION_PATH
  echo == Start... $APPDB_VERSION_TAG ==
  ls -lsa $MIGRATION_PATH

  echo -------------------------------------
  echo Apply migration SQL to database $APPDB_VERSION_TAG
  echo -------------------------------------

  PGPASSWORD=$ADEMPIERE_DB_PASSWORD
  export PGPASSWORD

  #i4.1
  cd $MIGRATION_PATH
  for sqlfile in *.sql; do
      echo $sqlfile
      psql -h $ADEMPIERE_DB_SERVER -p $ADEMPIERE_DB_PORT -U $ADEMPIERE_DB_USER -d $ADEMPIERE_DB_NAME -f $sqlfile
  done
}

run_migration $IDEMPIERE_HOME/data/seed/migration/i5.1/$ADEMPIERE_DB_PATH/$APPDB_VERSION_TAG
run_migration $IDEMPIERE_HOME/data/seed/migration/i5.1z/$ADEMPIERE_DB_PATH
run_migration $IDEMPIERE_HOME/data/seed/migration/i6.1/$ADEMPIERE_DB_PATH
#post migration
cd $IDEMPIERE_HOME/data/seed/migration/processes_post_migration/$ADEMPIERE_DB_PATH
for sqlfile in *.sql; do
    echo $sqlfile
    psql -h $ADEMPIERE_DB_SERVER -p $ADEMPIERE_DB_PORT -U $ADEMPIERE_DB_USER -d $ADEMPIERE_DB_NAME -f $sqlfile
done

echo == End. $APPDB_VERSION_TAG ==
