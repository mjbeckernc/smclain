%let pathname=/nfsshare/sashls2/mattb/XMB111;
%let rootdir=/nfsshare/sashls2/mattb/XMB111;

%let ptitle1=%str(Cardio101);
%let ptitle2=%str(Card-101 Final);

%let ddt=&pathname./doc/ddt.xls;
%let sdtm=&pathname./doc/sdtm.xls;

libname raw "&pathname./data/Rawdata";
libname sdtm "&pathname./data/SDTM";
*libname derived "&pathname./data/ADaM";
%sysfunc(ifc(%sysfunc(libref(derived)),libname derived "&pathname./data/ADaM",));

libname psmac   "&pathname./macros" access=read;
libname fmtdata "&pathname./data/ADaM";
libname library "&pathname./data/ADaM";

libname subdata "&pathname/WUSS2024";

PROC SURVEYSELECT DATA=raw.dm OUT=dm METHOD=SRS
  SAMPSIZE=25 SEED=1234567;
  RUN;

proc sort data=raw.ae out=ae;
  by StudyID SITE RANDOMNO;
proc sort data=dm;
  by StudyID SITE RANDOMNO;

data ae;
  merge dm(in=x) ae(in=y);
  by StudyID SITE RANDOMNO;
  if x;
run;

data ae;
  set ae;
  drop RecID sysLUDT sysEXPDT sysFlags;
run;

data dm;
  set dm;
  drop RecID INIT BRTHDTN sysLUDT sysEXPDT sysFlags;
run;

data subdata.ae;
  set ae;
run;

data subdata.dm;
  set dm;
run;