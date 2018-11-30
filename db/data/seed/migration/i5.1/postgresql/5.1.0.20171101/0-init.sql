CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- update ad_system
UPDATE ad_system
SET lastbuildinfo='5.1.0'
WHERE ad_system_id=0;

-- add APPLICATION_MAIN_VERSION into ad_sysconfig
INSERT INTO ad_sysconfig(
ad_sysconfig_id, ad_client_id, ad_org_id, created, updated, createdby, updatedby, isactive, name, value, description, entitytype, configurationlevel, ad_sysconfig_uu)
VALUES (99999, 0, 0, '2017-10-31', '2017-10-31', 100, 100, 'Y', 'APPLICATION_MAIN_VERSION', '5.1.0', 'Application Main Version', 'D', 'S', '00000000-0000-0000-0000-000000000000');

-- disable GardenWorld Accounting Processor
UPDATE c_acctprocessor SET isactive = 'N'
WHERE c_acctprocessor_id = 100;

-- setup ad_language
-- disable es_CO
UPDATE ad_language SET issystemlanguage = 'N', isloginlocale = 'N'
WHERE ad_language = 'es_CO';
-- enable zh_CN
UPDATE ad_language SET issystemlanguage = 'Y', isloginlocale = 'Y'
WHERE ad_language = 'zh_CN';
