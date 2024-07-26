********************************************************************************;
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\rtaebysev.sas
*** Programmer:     Matt Becker
*** Date Created:   04Feb2010
***
*** Input :         Derived AE
***
*** Output:         Adverse Events by preferred term and severity, descreasing total
***
*** Purpose:        To create the adverse events by preferred term and severity table
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
%macro rtaesev(progid=taesev1, aevar=aedecod, tcond=, up_limit=17, progcond=, col1text=Preferred Term, row1text=Any AE);

data ae;
  set &derdata..ae(where=(q_safeas='Y' and q_bcond ne 'Y' and aenone ne 'Y' and aete='Y'));
  &tcond;
  &progcond;
  if &aevar='' then do;
    put "The following AE term has no meddra code: " usubjid= aeterm=;
    &aevar=aeterm;
  end;
  output;
  if atrt in(2,3,4) then do;
    atrt=5;
    output;
  end;
  atrt=6;
  output;
run;

%mtottrt(cond=%str(if q_safeas='Y';) &tcond);

%*** Create Any Preferred Term;
data ae;
  set ae;
  output;
  if &aevar ne '' then do;
    &aevar='AAAAA';
    output;
  end;
run;

%*** Create severities of any, >2, 1, 2, 3;
data ae;
  set ae;
  output;
  if aetoxgr>2 then do;
    aetoxgr=-55;
    output;
  end;
run;

%*** Remove severities >=4;
data ae;
  set ae;
  if aetoxgr>=4 then delete;
run;

%*** Create Any Severity;
data ae;
  set ae;
  output;
  if &aevar ne '' then do;
    aetoxgr=-99;
	output;
  end;
run;

proc sort data=ae out=ae nodupkey;
  by atrt usubjid &aevar aetoxgr;

%mfreq(mfdata=ae, mfout=aestats, mfby=aetoxgr, mfcntvar=&aevar, mforder=1);

proc sort data=aestats;
  by &aevar aetoxgr;

data aestats;
  set aestats;
  by &aevar aetoxgr;
  retain order;
  if _n_=1 then order=1;
  length severity $25;
  severity=put(aetoxgr,sevf.);
  if _n_>1 and first.&aevar then order+1;
run;

%*** Get the number of subjects from the total column for sorting purposes on the Any Severity row;
data ordertot(keep=&aevar totaln);
  set aestats(where=(aetoxgr=-99));
  length totaln 8;
  totaln=substr(trt6,1,index(trt6,'(')-1)*1;
run;

proc sort data=ordertot;
  by &aevar;

proc sort data=aestats;
  by &aevar;

data aestats;
  merge aestats(in=x) ordertot(in=y);
  by &aevar;
  if x;
run;

proc sort data=aestats;
  by descending totaln &aevar aetoxgr sorder;

data final;
  set aestats;
  by descending totaln &aevar aetoxgr sorder;
  length page 4;
  retain page;
  if first.&aevar then page=floor(_n_/15)+1;
  if &aevar='AAAAA' then &aevar='Any';
run;

proc sort data=final;
  by page descending totaln descending totaln &aevar aetoxgr;
run;

%mtitle(progid=&progid);

proc report data=final headline headskip nowindows split='|' missing spacing=1;
  column page totaln sorder &aevar severity ("Age Group (years) \brdrb\brdrs" trt1 trt2 trt3 trt4 trt5) trt6;
  define page /order noprint;
  define totaln / descending order noprint;
  define sorder /order noprint;
  define &aevar / order "&col1text.`{super a}" style={just=l cellwidth=25%};
  define severity / "Severity`{super b}" style={just=l cellwidth=7%};
  define trt1 / "     0 - 2 |     (N=&pop1)|     n (%)" style={cellwidth=8%};
  define trt2 / "     3 - 6 |     (N=&pop2)|     n (%)" style={cellwidth=8%};
  define trt3 / "     7 - 11 |     (N=&pop3)|     n (%)" style={cellwidth=8%};
  define trt4 / "     12 - &up_limit |     (N=&pop4)|     n (%)" style={cellwidth=8%};
  define trt5 / "     3 - &up_limit Total |     (N=&pop5)|     n (%)" style={cellwidth=8%};
  define trt6 / "     Total`{super c} |     (N=&pop6)|     n (%)" style={cellwidth=8%};
  break after page / page;
  compute before sorder;
    line " ";
  endcomp;
run;

ods rtf close;
ods listing;

%mpageof;

%mend rtaesev;

%*** AEs by Severity by decreasing count;
%rtaesev(progid=taesev1, tcond=);
%rtaesev(progid=taesev2, tcond=%str(if age<17), up_limit=16);
