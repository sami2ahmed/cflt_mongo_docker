# install sql plus 
sudo su
curl https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-basic-21.9.0.0.0-1.el8.x86_64.rpm --output instant-basic.rpm
rpm -i instant-basic.rpm
curl https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-sqlplus-21.6.0.0.0-1.el8.x86_64.rpm --output instant-client.rpm
rpm -i instant-client.rpm
​
# controlling oracle from EC2 
sqlplus samiadmin@sami-oracle-rds.cndsjke6xo5r.us-west-2.rds.amazonaws.com:1521/ORACLE 
​
# commands to allow CDC to be run on the DB once on the SQL prompt 
​
CREATE USER DB_USER IDENTIFIED BY PASSWORD DEFAULT TABLESPACE USERS;
ALTER USER DB_USER QUOTA UNLIMITED ON USERS;
​
GRANT CREATE SESSION TO DB_USER;
GRANT SELECT ON DBA_TABLESPACES TO DB_USER;
GRANT LOGMINING TO DB_USER;
​
GRANT SELECT ON CUSTOMERS TO DB_USER;
​
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_VIEWS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_TAB_PARTITIONS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_INDEXES', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_OBJECTS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_TABLES', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_USERS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_CATALOG', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_CONSTRAINTS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_CONS_COLUMNS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_TAB_COLS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_IND_COLUMNS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_LOG_GROUPS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVED_LOG', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOG', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGFILE', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$THREAD', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$NLS_PARAMETERS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TIMEZONE_NAMES', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TRANSACTION', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_REGISTRY', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('OBJ$', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_ENCRYPTED_COLUMNS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_LOGS', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_CONTENTS','DB_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOGMNR', 'DB_USER', 'EXECUTE');
​
-- The following privileges are required additionally for 19c compared to 12c
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_TABLESPACES', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$INSTANCE', 'DB_USER', 'SELECT');
exec rdsadmin.rdsadmin_util.alter_supplemental_logging(p_action => 'ADD');