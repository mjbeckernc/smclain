********************************************************************************;
***
*** Program:        XMB111/programs/d0_dm.sas
*** Programmer:     Matt Becker
*** Date Created:   02Jun2024
***
*** Input :         SDTM DM, DS, VS
***
*** Output:         Derived DM dataset
***
*** Purpose:        To create the derived DM dataset
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
data dm;
  set &rawdata..dm(drop=race);
  length age atrt x_race dmdtn 8 x_raceot $70 domain $2 usubjid $25 subjid $14 ageu brthdtc dmdtc $10 race $100 arm $20 armcd $8
         country $3 sexn 4;
  format brthdtn dmdtn date9.;
  domain='DM';
  arm='Nicardopine';
  armcd='A';
  country='USA';
  studyid='XMB111';
  usubjid=trim(left(studyid))||'-'||trim(left(site))||'-'||trim(left(randomno));
  subjid=trim(left(site))||'-'||trim(left(randomno));
  brthdtc=put(brthdtn,yymmdd10.);
  dmdtn=dov;
  dmdtc=put(dmdtn,yymmdd10.);
  age=round((intck('month',brthdtn,dmdtn) - (day(dmdtn) < day(brthdtn))) / 12,.1);
  ageu='Years';
  atrt=(0<=age<=2.9)*1 + (3<=age<=6.9)*2 + (7<=age<=11.9)*3 + (12<=age<=17.9)*4;
  if atrt not in(1, 2, 3, 4) then put "Age does not fit in any age group" usubjid=;
  race=trim(left(racec));
  if upcase(racec)="AMERICAN INDIAN OR ALASKA NATIVE" then x_race=1;
  else if upcase(racec)="ASIAN" then x_race=2;
  else if upcase(racec)="BLACK OR AFRICAN AMERICAN" then x_race=3;
  else if upcase(racec)="HISPANIC" then x_race=4;
  else if upcase(racec)="NATIVE HAWAIIAN/PACIFIC ISLANDER" then x_race=5;
  else if upcase(racec)="WHITE" then x_race=6;
  else x_race=7;
  if sex='M' then sexn=1;
  else if sex='F' then sexn=2;
  if raceoth ne '' then x_raceot=raceoth;
run;

proc sort data=dm;
  by site randomno;

%*** Get study drug start from SDA dataset;
proc sort data=&rawdata..sda out=sda(keep=site randomno exdtc);
  by site randomno exdtc;
  where exyn='Y';

data sda(rename=(exdtc=rfstdtn));
  set sda;
  by site randomno exdtc;
  if first.randomno;
run;

data dm;
  merge dm(in=x) sda(in=y);
  length rfstdtc $10;
  by site randomno;
  if x;
  rfstdtc=put(rfstdtn,yymmdd10.);
run;

%*** Get reference end date from DS dataset;
proc sort data=&rawdata..ds out=ds(keep=site randomno dsstdtc rename=(dsstdtc=rfendtn));
  by site randomno;
  where dsdecod not in(11,12);

data dm;
  merge dm(in=x) ds(in=y);
  by site randomno;
  length rfendtc $10;
  if x;
  rfendtc=put(rfendtn,yymmdd10.);
run;

%*** Get date of consent, did subject meet all eligibility criteria from the OE panel;
proc sort data=&rawdata..oe out=oe(keep=site randomno cnstdtn oeelig rename=(oeelig=q_oeelig));
  by site randomno;
  where cnstdtn ne .;

data oe;
  set oe;
  by site randomno;
  if first.randomno;
run;

data dm;
  merge dm(in=x) oe(in=y);
  by site randomno;
  length dmdy 8 q_infcst q_noteli q_safeas $1;
  if x;
  if cnstdtn ne . then q_infcst='Y';
  else q_infcst='N';
  if q_infcst='Y' and q_oeelig='N' then q_noteli='Y';
  else q_noteli='N';
  if rfstdtn ne . then q_safeas='Y';
  else q_safeas='N';
  %mstudydy(todate=dmdtn,basedate=rfstdtn,studyday=dmdy);
run;

%*** Get disposition information;
proc sort data=&rawdata..ds out=ds(keep=site randomno dsyn dsdecod dsdecodc dsrsntrc dsrsntr rename=(dsyn=q_comp));
  by site randomno;

data dm(rename=(dsdecodc=dsdecod));
  merge dm(in=x) ds(in=y);
  by site randomno;
  length q_eligmd $1 dsdecodn medrecn 8 medrecd $100;
  if x;
  if dsdecod=12 then q_eligmd='Y';
  else q_eligmd='N';
  dsdecodn=dsdecod;
  medrecd=dsrsntrc;
  medrecn=dsrsntr;
  drop dsdecod;
run;

%*** Get immunogenecity information;
proc sort data=&rawdata..spc out=spc(keep=site randomno visit);
  by site randomno visit;
  where spyn='Y';

data spc(drop=visit);
  set spc;
  by site randomno visit;
  length flagx $15 q_immuas $1;
  retain flagx;
  if first.randomno then flagx='';
  flagx=trim(left(flagx))||' '||trim(left(put(visit,3.)));
  if last.randomno then do;
    if index(flagx,'0 ') and (index(flagx,'1 ') or index(flagx,'2 ') or index(flagx,'29 ')) then q_immuas='Y';
	else q_immuas='N';
	output;
  end;
run;
  
data dm;
  merge dm(in=x) spc(in=y);
  by site randomno;
  if x;
  if rfstdtn ne . and q_immuas='Y' then q_immuas='Y';
  else q_immuas='N';
run;

%*** Get height and weight;
proc sort data=&rawdata..vs out=vs(keep=site randomno ornht ornwt ornhtu ornwtu);
  by site randomno;
  where visit=0;

data dm(rename=(site=siteid));
  merge dm(in=x) vs(in=y);
  by site randomno;
  length height weight tbsa 8;
  if x;
  if upcase(ornhtu)='CM' then height=ornht;
  else if upcase(ornhtu)='IN' then height=ornht*2.54;
  if upcase(ornwtu)='KG' then weight=ornwt;
  else if upcase(ornwtu)='LBS' then weight=ornwt*0.454;
  tbsa=sqrt((height*weight)/3600);
run;

proc casutil;
	load data=derived.dm outcaslib="public"
	casout="XMB111_DM" replace;
    promote incaslib="public" casdata="XMB111_DM" outcaslib="public";
run;

%mimpddt(micsv=DM, miin=dm, miout=&derdata..dm, mlbl=DM Analysis Dataset);
