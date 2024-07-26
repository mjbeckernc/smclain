********************************************************************************;
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\rtconmed.sas
*** Programmer:     Matt Becker
*** Date Created:   03Feb2010
***
*** Input :         Derived CM
***
*** Output:         Concomitant Medication Use table
***
*** Purpose:        To create the concomitant medication use table
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
%macro rtconmed(progid=tconmed1, tcond=, up_limit=17);

data cm;
  set &derdata..cm(where=(q_safeas='Y'));
  &tcond;
  output;
  if atrt in(2,3,4) then do;
    atrt=5;
	output;
  end;
  atrt=6;
  output;
run;

%mtottrt(cond=%str(if q_safeas='Y';) &tcond);

%*** Create Any Medication and No Medication records;
data cm;
  set cm;
  if cmnone='Y' then cmdecod='AAAAB';
  output;
  if cmnone ne 'Y' and cmdecod ne '' then do;
    cmdecod='AAAAA';
	output;
  end;
run;

proc sort data=cm out=cm nodupkey;
  by atrt usubjid cmdecod;

%mfreq(mfdata=cm, mfout=cmstats, mfcntvar=cmdecod, mforder=1);

data final;
  set cmstats;
  length page 4;
  page=floor(_n_/20);
run;

proc sort data=final;
  by page order sorder;
run;

data final;
  set final;
  by page order sorder;
  if cmdecod='AAAAA' then do;
    cmdecod='Any Medication Use';
	output;
	cmdecod=''; trt1=''; trt2=''; trt3=''; trt4=''; trt5=''; trt6='';
	output;
  end;
  else if cmdecod='AAAAB' then do;
    cmdecod='No Medication Use';
	output;
	cmdecod=''; trt1=''; trt2=''; trt3=''; trt4=''; trt5=''; trt6='';
	output;
  end;
  else output;
run;

%mtitle(progid=&progid);

proc report data=final headline headskip nowindows split='|' missing spacing=1;
  column page order sorder cmdecod ("Age Group (years) \brdrb\brdrs" trt1 trt2 trt3 trt4 trt5) trt6;
  define page /order noprint;
  define order /order noprint;
  define sorder /order noprint;
  define cmdecod / "WHO Drug Term`{super a}" style={just=l cellwidth=30%};
  define trt1 / "     0 - 2 |     (N=&pop1)|     n (%)" style={cellwidth=10%};
  define trt2 / "     3 - 6 |     (N=&pop2)|     n (%)" style={cellwidth=10%};
  define trt3 / "     7 - 11 |     (N=&pop3)|     n (%)" style={cellwidth=10%};
  define trt4 / "     12 - &up_limit |     (N=&pop4)|     n (%)" style={cellwidth=10%};
  define trt5 / "     3 - &up_limit Total |     (N=&pop5)|     n (%)" style={cellwidth=10%};
  define trt6 / "     Total |     (N=&pop6)|     n (%)" style={cellwidth=10%};
  break after page / page;
/*
  compute before order;
    line " ";
  endcomp;
*/
run;

ods rtf close;
ods listing;

%mpageof;

%mend rtconmed;
%rtconmed(progid=tconmed1, tcond=);
%rtconmed(progid=tconmed2, tcond=%str(if age<17), up_limit=16);
