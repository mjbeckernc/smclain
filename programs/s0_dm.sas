********************************************************************************;
***
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\s0_dm.sas
*** Programmer:     Matt Becker
*** Date Created:   20Mar2010
***
*** Input :         RAW DM, RAW SDA
***
*** Output:         SDTM DM
***
*** Purpose:        Create the DM SDTM domain
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

proc format;
  value $sex 'M'='MALE'
             'F'='FEMALE';
quit;

data dm(drop=sex race rename=(sexnew=sex racenew=race)) suppdm(keep=&suppkeep);
  set &rawdata..dm;
  length usubjid $25 idvarval $200;
  usubjid=trim(left(studyid))||'-'||trim(left(site))||'-'||trim(left(randomno));
  domain='DM';
  brthdtc=put(brthdtn,yymmdd10.);
  sexnew=put(sex,$sex.);
  racenew=racec;
  arm='RTHROMBIN';
  armcd='RTHROMBIN';
  ageu='YEARS';
  output dm;
  if init ne '' then do;
    %msuppq(outfile=suppdm, rdomain=DM, idvar=usubjid, qnam=init, qlabel=%str(SUBJECT INITIALS), qorig=CRF);
  end;
  if raceoth ne '' then do;
    %msuppq(outfile=suppdm, rdomain=DM, idvar=usubjid, qnam=raceoth, qlabel=%str(RACE, OTHER), qorig=CRF);
  end;
run;

proc sort data=dm;
  by site randomno;

proc sort data=&rawdata..sda out=sda(keep=site randomno exdtc);
  by site randomno;
  where exyn='Y';

data dm(rename=(site=siteid randomno=subjid));
  merge dm(in=x) sda(in=y);
  by site randomno;
  keep studyid usubjid site randomno domain brthdtc sex race rfstdtc rfendtc ageu arm armcd age dmdtc dmdy;
  if x;
  rfstdtc=put(exdtc,yymmdd10.);
  rfendtc=put(exdtc,yymmdd10.);
  age=round((intck('month',input(brthdtc,yymmdd10.),input(rfstdtc,yymmdd10.)) - (day(input(rfstdtc,yymmdd10.)) < day(input(brthdtc,yymmdd10.)))) / 12,.1);
  dmdtc=put(dov,yymmdd10.);
  dmdy=dov-input(rfstdtc,yymmdd10.);
  if dmdy>=0 then dmdy+1;
run;

%mimpsdtm(micsv=DM, miin=dm, miout=sdtm.dm, mlbl=DM SDTM Dataset);
%mimpsdtm(micsv=SUPP, miin=suppdm, miout=sdtm.suppdm, mlbl=Supplemental DM SDTM Dataset);
