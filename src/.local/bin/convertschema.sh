#/bin/bash

SCHEMA=$1
EXCLUDES=".*_gadget.* .*_attribute.* log_*"
TARGET_DIR=$HOME/share/postgresql/convert

if [ -z $SCHEMA ]; then
    echo $0 need a schema name for extraction
    exit
fi

ORACLE_DSN="dbi:Oracle:devices"
ORACLE_USER="odbadm"
ORACLE_PWD="sy2004_"
echo setting source to $ORACLE_USER@$ORACLE_DSN

TARGET_DIR=$HOME/share/postgresql/convert
if [ -x $TARGET_DIR -o -x $TARGET_DIR ]; then
    echo set target location to $TARGET_DIR
    ls -l $TARGET_DIR/*
else
    echo creating target $TARGET_DIR
    mkdir -p $TARGET_DIR
fi
SCHEMA_DIR="$TARGET_DIR/"$SCHEMA"_"`date +%FT%T`
echo "setting schema location to $SCHEMA_DIR"

if [ -x $SCHEMA_DIR -o -x $SCHEMA_DIR ]; then
    echo "cleaning existing schema location $SCHEMA_DIR" 
    rm -rf $SCHEMA_DIR/*
else
    echo "creating schema location $SCHEMA_DIR"
    mkdir $SCHEMA_DIR
fi
echo 'CREATE SCHEMA ' $SCHEMA ';' >$SCHEMA_DIR/SCHEMA.sql

for TOO in SEQUENCE TABLE VIEW GRANT TRIGGER FUNCTION DATA; do
    echo "extracting $TOO"
    ora2pg -b $SCHEMA_DIR -s $ORACLE_DSN -u $ORACLE_USER -w $ORACLE_PWD -n $SCHEMA -e $EXCLUDES -t $TOO -o $TOO.sql
    sed "s/SET client_encoding TO 'LATIN1';//" -i $SCHEMA_DIR/$TOO.sql
    sed "s/\\set ON_ERROR_STOP ON//" -i $SCHEMA_DIR/$TOO.sql
done
echo Patching $SCHEMA to sequence
sed "s/SEQUENCE seq_/SEQUENCE $SCHEMA.seq_/" -i $SCHEMA_DIR/SEQUENCE.sql 
echo Patching $SCHEMA to table
sed "s/TABLE tbl_/TABLE $SCHEMA.tbl_/" -i $SCHEMA_DIR/TABLE.sql
sed "s/TABLE log_/TABLE $SCHEMA.log_/" -i $SCHEMA_DIR/TABLE.sql
sed "s/INDEX idx_/TABLE $SCHEMA.idx_/" -i $SCHEMA_DIR/TABLE.sql
sed "s/device\.tbl_/$SCHEMA.tbl_/" -i $SCHEMA_DIR/VIEW.sql
sed "s/REFERENCES tbl_/REFERENCES $SCHEMA.tbl_/" -i $SCHEMA_DIR/TABLE.sql
echo Patching $SCHEMA to trigger
sed "s/TRIGGER trg_/TRIGGER $SCHEMA.trg_/" -i $SCHEMA_DIR/TRIGGER.sql
sed "s/EXISTS trg_/EXISTS $SCHEMA.trg_/" -i $SCHEMA_DIR/TRIGGER.sql
sed "s/trigger_fct_trg_/$SCHEMA.trg_/" -i $SCHEMA_DIR/TRIGGER.sql
sed "s/ ON tbl_/ ON $SCHEMA.tbl_/" -i $SCHEMA_DIR/TRIGGER.sql
sed "s/PERFORM /SELECT /" -i $SCHEMA_DIR/TRIGGER.sql
echo Patching $SCHEMA to views
sed "s/device\.v_/$SCHEMA.v_/" -i $SCHEMA_DIR/VIEW.sql
sed "s/device\.tbl_/$SCHEMA.tbl_/" -i $SCHEMA_DIR/VIEW.sql
sed "s/REPLACE VIEW v_/REPLACE VIEW $SCHEMA.v_/" -i $SCHEMA_DIR/VIEW.sql 
echo Patching $SCHEMA to data
sed "s/INTO tbl_/INTO $SCHEMA.tbl_/" -i $SCHEMA_DIR/DATA.sql
sed "s/INTO log_/INTO $SCHEMA.log_/" -i $SCHEMA_DIR/DATA.sql
echo Patching done...
ls -l $SCHEMA_DIR
