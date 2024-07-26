********************************************************************************;
*** Program:        /nfsshare/sashls2/mattb/XMB111/snowfl_programs/snowfl_programs/rldemo.sas
*** Programmer:     Matt Becker
*** Date Created:   11Jun2024
***
*** Input :         SDTM DM, STDM VS, SDTM SUPPDM
***
*** Output:         Listing 9:  Demographics and Subject Characteristics
***
*** Purpose:        To create the listing of demographics and subject characteristics
***
*** Comments:
***
*** Software:       SAS 9 (Windows)
***
*** Modifications:
***
*** Date       Programmer        Description
*** ---------  ----------------  --------------
***
********************************************************************************;
proc sort data=snowlib.vs out=vs;
  by usubjid;
  where visitnum=0 and vstestcd in('ORNHT','ORNWT');

proc transpose data=vs out=tranvs(drop=_name_);
  by usubjid;
  var vsstresn;
  id vstest;
run;

proc sort data=snowlib.dm out=dm;
  by usubjid;

data dm;
  merge dm(in=x) tranvs(in=y);
  by usubjid;
  length tbsa 8;
  if x;
  tbsa=sqrt((height*weight)/3600);
run;

proc sort data=snowlib.suppdm out=suppdm(keep=usubjid qval);
  by usubjid;
  where qnam='INIT';

data dm(rename=(qval=init));
  merge dm(in=x) suppdm(in=y);
  by usubjid;
  if x;
  page=int(_n_/8)+1;
run;

%mcase(inds=dm, exceptl=%str('USUBJID','INIT','BRTHDTC'));

%mtitle(progid=ldemo);

proc report data=dm headline headskip nowindows split='|' missing spacing=1;
  column page usubjid init brthdtc age sex race height weight tbsa;
  define page / order noprint;
  define usubjid / order 'Subject' style={just=left cellwidth=7%};
  define init / display 'Initials' style={just=left cellwidth=6%};
  define brthdtc / display 'Date of Birth' style={just=left cellwidth=10%};
  define age / order 'Age|(Years)' format=4.1 style={just=center cellwidth=7%};
  define sex / display 'Gender' style={just=left cellwidth=7%};
  define race / display 'Race' style={just=left cellwidth=22%};
  define height / display 'Height|(cm)' format=3. style={just=left cellwidth=8%};
  define weight / display 'Weight|(kg)' format=3. style={just=left cellwidth=8%};
  define tbsa / display "TBSA`{super a}" format=4.1 style={just=left cellwidth=8%};
  break after page / page;
  compute before usubjid;
    line " ";
  endcomp;
run;

ods rtf close;
ods listing;

%mpageof;
