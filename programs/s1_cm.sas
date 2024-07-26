********************************************************************************;
***
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\s1_cm.sas
*** Programmer:     Matt Becker
*** Date Created:   30Mar2010
***
*** Input :         RAW CM, RAW CODECM, SDTM DM
***
*** Output:         SDTM CM
***
*** Purpose:        Create the CM SDTM domain
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

data cm(drop=visit cmstdtc cmendtc cmroute
        rename=(visitnew=visit cmstdtc_new=cmstdtc cmendtc_new=cmendtc cmroute_new=cmroute));
  set &rawdata..cm;
  length usubjid $25 visitnew $25 cmtrt $200 ;
  usubjid=trim(left(studyid))||'-'||trim(left(site))||'-'||trim(left(randomno));
  domain='CM';
  if cmnone='Y' then cmstat='ND';
  if cmstat ne 'ND' then do; 
    %msdtmdt(datepart=cmstdt, datevar=cmstdtc_new);
    %msdtmdt(datepart=cmendt, datevar=cmendtc_new);
  end;
  cmcat='CONCOMITANT MEDICATIONS';
  cmseq='15';
  cmgrpid=trim(left(cmform));
  visitnum=visit;
  visitnew=upcase(put(visitnum,visitf.));
  if cmongo='Y' then cmenrf='ONGOING';
  cmtrt=cmterm;
  cmroute_new=cmroutec;
run;

%msdtmdy(inds=cm, todate=cmstdtc, studyday=cmstdy);
%msdtmdy(inds=cm, todate=cmendtc, studyday=cmendy);

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

proc sort data=cm;
  by studyid domain usubjid cmseq cmgrpid cmspid;

%mimpsdtm(micsv=CM, miin=CM, miout=sdtm.CM, mlbl=CM SDTM Dataset);
