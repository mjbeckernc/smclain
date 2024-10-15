********************************************************************************;
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\rtae.sas
*** Programmer:     Matt Becker
*** Date Created:   04Feb2010
***
*** Input :         Derived AE
***
*** Output:         Adverse Events by SOC and Preferred Term
***
*** Purpose:        To create the adverse events by soc and preferred term
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
  value $anyrow "AAAAB"="Any AE                                                   ";
run;

%macro rtae(progid=tae1, aevar=aedecod, tcond=, up_limit=17, progcond=, itprogid=);

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

%*** Create Any Preferred Term, Any SOC;
data ae;
  set ae;
  output;
  if &aevar ne '' then do;
    &aevar='AAAAB';
    output;
	aebodsys='Any SOC';
	output;
  end;
run;

proc sort data=ae out=ae nodupkey;
  by atrt usubjid aebodsys &aevar;

%mfreq(mfdata=ae, mfout=aestats, mfby=aebodsys, mfcntvar=&aevar, mforder=1);

proc sort data=aestats;
  by aebodsys &aevar;

data final;
  set aestats;
  by aebodsys &aevar;
  length page 4;
  retain page;
  if first.&aevar then page=floor(_n_/15)+1;
  if &aevar='AAAAB' then &aevar="Any AE";
run;

%mnumobs(inds=final);

%macro numobs;
%if &nobs=1 %then %do;
  data final;
    set final;
    if &aevar='' then do;
      &aevar='None Reported'; trt1=''; trt2=''; trt3=''; trt4=''; trt5=''; trt6='';
    end;
  run;
%end;
%mend numobs;
%numobs;

proc sort data=final;
  by page aebodsys &aevar;

%mtitle(progid=&progid, type=html);

proc report data=final headline headskip nowindows split='|' missing spacing=1;
  column page aebodsys sorder &aevar ("Age Group (years) \brdrb\brdrs" trt1 trt2 trt3 trt4 trt5) trt6;
  define page /order noprint;
  define aebodsys /order "SOC`{super a}" format=$anyrow. style={just=l cellwidth=20%};
  define sorder /order noprint;
  %if &progid=tae1 or &progid=tae2 %then %do;
    define &aevar / "Preferred Term`{super a}" format=$anyrow. style={just=l cellwidth=20%};
  %end;
  %else %do;
    define &aevar / "Preferred Term`{super b}" format=$anyrow. style={just=l cellwidth=20%};
  %end;
  define trt1 / "     0 - 2 |     (N=&pop1)|     n (%)" style={cellwidth=8%};
  define trt2 / "     3 - 6 |     (N=&pop2)|     n (%)" style={cellwidth=8%};
  define trt3 / "     7 - 11 |     (N=&pop3)|     n (%)" style={cellwidth=8%};
  define trt4 / "     12 - &up_limit |     (N=&pop4)|     n (%)" style={cellwidth=8%};
  define trt5 / "     3 - &up_limit Total |     (N=&pop5)|     n (%)" style={cellwidth=8%};
  define trt6 / "     Total |     (N=&pop6)|     n (%)" style={cellwidth=8%};
  break after page / page;
  compute before aebodsys;
    line " ";
  endcomp;
run;

ods rtf close;
ods listing;

%mpageof;

%if &itprogid ne %then %do;

  %mtitle2(progid=&itprogid, orient=P, type=html);

  proc report data=final headline headskip nowindows split='|' missing spacing=1;
    column page sorder &aevar ("Age Group (years) \brdrb\brdrs" trt1 trt2 trt3 trt4) trt6;
    define page /order noprint;
    define sorder /order noprint;
    define &aevar / "Preferred Term`{super b}" format=$anyrow. style={just=l cellwidth=20%};
    define trt1 / "     0 - 2 |     (N=&pop1)|     n (%)" style={cellwidth=8%};
    define trt2 / "     3 - 6 |     (N=&pop2)|     n (%)" style={cellwidth=8%};
    define trt3 / "     7 - 11 |     (N=&pop3)|     n (%)" style={cellwidth=8%};
    define trt4 / "     12 - &up_limit |     (N=&pop4)|     n (%)" style={cellwidth=8%};
    define trt6 / "     Total |     (N=&pop6)|     n (%)" style={cellwidth=8%};
    break after page / page;
/*
    compute before &aevar;
      if lag1(&aevar)='Any AE' then line " ";
    endcomp;  
*/
  run;

  ods rtf close;
  ods listing;

  %mpageof;

%end;

%mend rtae;

%*** AEs by SOC and Preferred Term;
%rtae(progid=tae1, tcond=);
%*rtae(progid=tae2, tcond=%str(if age<17), up_limit=16);

%*** Treatment-Related AEs by SOC and Preferred Term;
%*rtae(progid=tae3, tcond=, progcond=%str(if aetrtrel='Y'), itprogid=tae9a);
%*rtae(progid=tae4, tcond=%str(if age<17), up_limit=16, progcond=%str(if aetrtrel='Y'), itprogid=tae9b);
