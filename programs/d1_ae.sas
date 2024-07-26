********************************************************************************;
***
*** Program:        XMB111/programs/d1_ae.sas
*** Programmer:     Matt Becker
*** Date Created:   02Jun2024
***
*** Input :         RAW AE, Derived DM
***
*** Output:         Derived AE dataset
***
*** Purpose:        To create the derived AE dataset
***
*** Comments:
***
*** Software:       SAS Viya 4
***
*** Modifications:
***
*** Date       Programmer        Description
*** ---------  ----------------  --------------
***
********************************************************************************;
data ae(drop=aeendtc aestdtc);
  set &rawdata..ae(drop=aeout aerel rename=(aeacn=aeacnn));
  length domain aecontrt $2 usubjid aeacn $25 aeacnoth $200 aeendtn aestdtn 8 aedur 4 aeout aerel aesev $50 q_addtrt $7
         q_aerslv $10;
  format aeendtn aestdtn date9.;
  domain='AE';
  usubjid=trim(left('XMB111'))||'-'||trim(left(site))||'-'||trim(left(randomno));
  aeacn=aeacnc;
  aeacnoth=aeacnosp;
  aecontrt=aecontr;
  aeendtn=aeendtc;
  aestdtn=aestdtc;
  aedur=aeendtn-aestdtn + (aeendtn>=aestdtn);
  aeout=aeoutc;
  aerel=aerelc;
  aesev=aetoxgrc;
  if upcase(aerel) in('POSSIBLY RELATED','PROBABLY RELATED','RELATED') then aetrtrel='Y';
  else aetrtrel='N';
  q_addtrt=aeaddyn;
  if aeongo='Y' then q_aerslv='ONGOING';
run;

data bc(rename=(bcspid=aespid bcnone=aenone bcterm=aeterm bcser=aeser));
  set &rawdata..bc;
  keep site randomno studyid domain usubjid bcnone bcterm bcspid bcser q_bcond aestdtn aeendtn aecontrt aesev q_addtrt
       q_aerslv;
  length domain aecontrt $2 usubjid $25 aeendtn aestdtn 8 aesev $50 q_bcond $1 q_addtrt $7 q_aerslv $10;
  format aeendtn aestdtn date9.;
  domain='AE';
  usubjid=trim(left('XMB111'))||'-'||trim(left(site))||'-'||trim(left(randomno));
  aecontrt=bccontr;
  aeendtn=bcendtc;
  aestdtn=bcstdtc;
  aesev=bctoxgrc;
  q_bcond='Y';
  q_addtrt=bcaddyn;
  if bcongo='Y' then q_aerslv='ONGOING';
run;
  
data ae;
  set ae bc;
run;
 
proc sort data=ae;
  by usubjid;

proc sort data=&derdata..dm out=dm(keep=&demovars.);
  by usubjid;

data ae;
  merge ae(in=x) dm(in=y);
  by usubjid;
  length aeendtc aestdtc $10;
  if x;
  aeendtc=put(aeendtn,yymmdd10.);
  aestdtc=put(aestdtn,yymmdd10.);
  if q_aerslv ne 'ONGOING' then q_aerslv=aestdtc;
  %mstudydy(todate=aestdtn,basedate=rfstdtn,studyday=aestdy);
  %mstudydy(todate=aeendtn,basedate=rfstdtn,studyday=aeendy);
run;

proc sort data=ae out=allae;
  by aeterm;
  where q_bcond ne 'Y';
proc sort data=raw.codeae out=codeae;
  by aeterm;

data allae;
  merge allae(in=x) codeae(in=y);
  by aeterm;
  length aebodsys aedecod $200;
  if x;
  aebodsys=upcase(socterm);
  aedecod=upcase(prefterm);
run;

proc sort data=ae out=allbc;
  by aeterm;
  where q_bcond eq 'Y';

proc sort data=raw.codebc out=codebc(rename=(bcterm=aeterm));
  by bcterm;

data allbc;
  merge allbc(in=x) codebc(in=y);
  by aeterm;
  length aebodsys aedecod $200;
  if x;
  aebodsys=upcase(socterm);
  aedecod=upcase(prefterm);
run;

%*** Derive AETE, Subject Year;
data ae;
  set allae allbc;
  length subjyr 8;
  if aenone ne 'Y' and aestdtn>=rfstdtn then aete='Y';
  else aete='-';
  subjyr=((rfendtn-rfstdtn)+1)/365.25;
run;

/*
proc sort data=ae;
  by usubjid prefterm aestdtn aetoxgr;

data ae;
  set ae;
  by usubjid prefterm aestdtn aetoxgr;
  if first.prefterm and aestdy<=0 and aete='-' and not last.prefterm and first.aetoxgr and not last.aetoxgr then aete='Y';
  else if aete='Y' then aete='Y';
  else aete='N';
run;
*/

proc casutil;
	load data=derived.ae outcaslib="public"
	casout="XMB111_AE" replace;
    promote incaslib="public" casdata="XMB111_AE" outcaslib="public";
run;

%mimpddt(micsv=AE, miin=AE, miout=&derdata..AE, mlbl=Adverse Event Analysis Dataset);
