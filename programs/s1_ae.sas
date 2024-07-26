********************************************************************************;
***
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\s1_ae.sas
*** Programmer:     Matt Becker
*** Date Created:   30Mar2010
***
*** Input :         RAW AE, RAW CODEAE, SDTM DM
***
*** Output:         SDTM AE
***
*** Purpose:        Create the AE SDTM domain
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

data ae(drop=visit aestdtc aeendtc aeacn aerel aeout 
        rename=(visitnew=visit aestdtc_new=aestdtc aeendtc_new=aeendtc aeacn_new=aeacn aerel_new=aerel aeout_new=aeout));
  set &rawdata..ae;
  length usubjid $25 visitnew $25 aesev aecat $50 aeenrf $15;
  usubjid=trim(left(studyid))||'-'||trim(left(site))||'-'||trim(left(randomno));
  domain='AE';
  if aenone='Y' then aeoccur='N';
  else aeoccur='Y';
  if aeoccur='Y' then do; 
    %msdtmdt(datepart=aestdt, datevar=aestdtc_new);
    %msdtmdt(datepart=aeendt, datevar=aeendtc_new);
  end;
  aecat='ADVERSE EVENTS';
  aeseq='14';
  visitnum=visit;
  visitnew=upcase(put(visitnum,visitf.));
  if aeongo='Y' then aeenrf='ONGOING';
  aesev=aetoxgrc;
  aeacn_new=aeacnc;
  aerel_new=aerelc;
  aeout_new=aeoutc;
  aecontrt=aecontr;
run;

%msdtmdy(inds=ae, todate=aestdtc, studyday=aestdy);
%msdtmdy(inds=ae, todate=aeendtc, studyday=aeendy);

proc sort data=ae;
  by aeterm;

proc sort data=raw.codeae out=codeae;
  by aeterm;

data ae;
  merge ae(in=x) codeae(in=y);
  by aeterm;
  length aebodsys aedecod $200;
  if x;
  aebodsys=upcase(socterm);
  aedecod=upcase(prefterm);
run;

proc sort data=ae;
  by studyid domain usubjid aeseq aespid;

%mimpsdtm(micsv=AE, miin=AE, miout=sdtm.ae, mlbl=AE SDTM Dataset);
