--setup lastbuildinfo and main version
UPDATE ad_system
SET lastbuildinfo='5.1.0.v20180116-0927'
WHERE ad_system_id=0;

UPDATE ad_sysconfig
SET value='5.1.0.v20180116-0927', updated='2018-01-08'
WHERE ad_sysconfig_id=99999;
