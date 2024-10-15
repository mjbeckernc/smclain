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

data subdata.dm(rename=(newsite=site newdov=dov));
  set subdata.dm;
  newsite=int(site/5 - 1);
  randomno=randomno-8000;
  newdov = intnx("year",dov,10,'same');
  format newdov mmddyy8.;
  drop site dov;
run;
          
data subdata.ae(rename=(newsite=site newdov=dov newstdt=AESTDTC newendt=AEENDTC));
  set subdata.ae;
  newsite=int(site/5 - 1);
  randomno=randomno-8000;
  newdov = intnx("year",dov,10,'same');
  newstdt = intnx("year",AESTDTC,10,'same');
  newendt = intnx("year",AEENDTC,10,'same');
  array adv_event [5] $200 ('ANEMIA' 'ANXIETY' 'PAIN' 'VOMITING' 'ITCHING');
  rand_int = rand('Integer', 1, 5);
  aeterm = adv_event(rand_int);
  if aeterm ne '' then aenone="";
  format newdov newstdt newendt mmddyy8.;
  drop site RecID sysLUDT sysEXPDT sysFlags SEX RACE RACEC RACEOTH dov rand_int AEHAYN adv_event1 adv_event2
       adv_event3 adv_event4 adv_event5 AESTDTDD AESTDTMM AESTDTYY AEENDTDD AEENDTMM AEENDTYY AEADDYN AEADDTRT
       aestdtc aeendtc;
run;