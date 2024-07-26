********************************************************************************;
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\d1_cm.sas
*** Programmer:     Matt Becker
*** Date Created:   01Feb2010
***
*** Input :         RAW CM, Derived DM
***
*** Output:         Derived CM dataset
***
*** Purpose:        To create the derived CM dataset
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
data cm(drop=cmendtc cmstdtc);
  set &rawdata..cm(drop=cmroute);
  length domain $2 usubjid $25 cmendtn cmstdtn 8 cmdur 4 cmroute $100 cmtrt $200;
  format cmendtn cmstdtn date9.;
  domain='CM';
  usubjid=trim(left(studyid))||'-'||trim(left(site))||'-'||trim(left(randomno));
  cmendtn=cmendtc;
  cmstdtn=cmstdtc;
  cmdur=cmendtn-cmstdtn + (cmendtn>=cmstdtn);
  cmtrt=trim(left(cmterm));
  cmroute=trim(left(cmroutec));
run;

proc sort data=cm;
  by usubjid;

proc sort data=&derdata..dm out=dm(keep=&demovars.);
  by usubjid;

data cm;
  merge cm(in=x) dm(in=y);
  by usubjid;
  length cmendtc cmstdtc $10;
  if x;
  cmendtc=put(cmendtn,yymmdd10.);
  cmstdtc=put(cmstdtn,yymmdd10.);
  %mstudydy(todate=cmstdtn,basedate=rfstdtn,studyday=cmstdy);
  %mstudydy(todate=cmendtn,basedate=rfstdtn,studyday=cmendy);
run;

proc sort data=cm;
  by cmtrt;
proc sort data=raw.codecm out=codecm;
  by cmtrt;

data cm;
  merge cm(in=x) codecm(in=y);
  by cmtrt;
  length cmdecod $200;
  if x;
  cmdecod=upcase(prefdrug);
run;

%mimpddt(micsv=CM, miin=CM, miout=&derdata..CM, mlbl=%str(Concomitant Medication Analysis Dataset));
