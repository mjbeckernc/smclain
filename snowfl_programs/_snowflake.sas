* This program pushes data used for TLF programs for demo purposes *;
* matbec 6/11/2024 *;

libname snowlib SASIOSNF server="sas_partner.east-us-2.azure.snowflakecomputing.com"
  user=robcol password=robcol schema=ROBCOL preserve_tab_names=yes;

libname rawdata "/nfsshare/sashls2/mattb/XMB111/data/Rawdata/";
libname sdtmdata "/nfsshare/sashls2/mattb/XMB111/data/SDTM/";
libname adamdata "/nfsshare/sashls2/mattb/XMB111/data/ADaM/";
libname library "/nfsshare/sashls2/mattb/XMB111/data/ADaM/";

proc sql;
   drop table snowlib.vs;
   drop table snowlib.dm;
   drop table snowlib.suppdm;
   drop table snowlib.ae;
   drop table snowlib.adae;
   drop table snowlib.adsl;
quit;
 
/* copy a table to snowflake */
data snowlib.vs;
   set sdtmdata.vs;
run;

data snowlib.dm;
  set sdtmdata.dm;
run;

data snowlib.suppdm;
  set sdtmdata.suppdm;
run;

data snowlib.ae;
  set sdtmdata.ae;
run;

data snowlib.adae;
  set adamdata.ae;
run;

data snowlib.adsl;
  set adamdata.dm;
run;

