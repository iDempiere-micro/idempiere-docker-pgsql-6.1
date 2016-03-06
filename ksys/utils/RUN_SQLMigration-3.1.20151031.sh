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

VERSION_TAG=3.1.20151031
MIGRATION_PATH=$IDEMPIERE_HOME/data/seed/migration/i3.1/$ADEMPIERE_DB_PATH/$VERSION_TAG

echo Last SQL Migration folder for seed database $MIGRATION_PATH
echo == Start... ($VERSION_TAG) ==
ls -lsa $MIGRATION_PATH

echo -------------------------------------
echo Apply migration SQL to database $VERSION_TAG
echo -------------------------------------

PGPASSWORD=$ADEMPIERE_DB_PASSWORD
export PGPASSWORD

#i3.1 
cd $MIGRATION_PATH
for sqlfile in *.sql; do
    echo $sqlfile
    psql -h $ADEMPIERE_DB_SERVER -p $ADEMPIERE_DB_PORT -U $ADEMPIERE_DB_USER -d $ADEMPIERE_DB_NAME -f $sqlfile
done

#i3.1z (4.0 dev)
#cd $IDEMPIERE_HOME/data/seed/migration/i3.1z/$ADEMPIERE_DB_PATH
#for sqlfile in *.sql; do
#    echo $sqlfile
#    psql -h $ADEMPIERE_DB_SERVER -p $ADEMPIERE_DB_PORT -U $ADEMPIERE_DB_USER -d $ADEMPIERE_DB_NAME -f $sqlfile
#done

#post migration
cd $IDEMPIERE_HOME/data/seed/migration/processes_post_migration/$ADEMPIERE_DB_PATH
for sqlfile in *.sql; do
    echo $sqlfile
    psql -h $ADEMPIERE_DB_SERVER -p $ADEMPIERE_DB_PORT -U $ADEMPIERE_DB_USER -d $ADEMPIERE_DB_NAME -f $sqlfile
done

echo == End. ($VERSION_TAG) ==
