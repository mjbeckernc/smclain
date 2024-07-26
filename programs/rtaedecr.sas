********************************************************************************;
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\rtaedecr.sas
*** Programmer:     Matt Becker
*** Date Created:   04Feb2010
***
*** Input :         Derived AE
***
*** Output:         Adverse Events by preferred term, descreasing total
***
*** Purpose:        To create the adverse events by preferred term table
***                 To create the >=3% adverse events by preferred term table
***                 To create the serious adverse events by preferred term table
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
%macro rtaedecr(progid=taedecr1, aevar=aedecod, tcond=, up_limit=17, progcond=, col1text=Preferred Term, row1text=Any AE,
                itprogid=, itbypct=Y);

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

proc sort data=ae out=ae nodupkey;
  by atrt usubjid &aevar;

%mfreq(mfdata=ae, mfout=aestats, mfcntvar=&aevar, mforder=1);

%*** Get the number of subjects from the total column for sorting purposes;
data aestats;
  set aestats;
  length totaln 8;
  totaln=substr(trt6,1,index(trt6,'(')-1)*1;
run;

proc sort data=aestats;
  by descending totaln order sorder;

data final;
  set aestats;
  by descending totaln order sorder;
  length page 4;
  page=floor(_n_/25)+1;
run;

proc sort data=final;
  by descending totaln page order sorder;
run;

data final;
  set final;
  by descending totaln page order sorder;
  if &aevar='AAAAA' then do;
    &aevar="&row1text.";
	output;
	totaln=totaln; &aevar=' '; trt1=''; trt2=''; trt3=''; trt4=''; trt5=''; trt6='';
	output;
  end;
  else output;
run;

%mtitle(progid=&progid);

proc report data=final headline headskip nowindows split='|' missing spacing=1;
  column page totaln order sorder &aevar ("Age Group (years) \brdrb\brdrs" trt1 trt2 trt3 trt4 trt5) trt6;
  define page /order noprint;
  define totaln / descending order noprint;
  define order /order noprint;
  define sorder /order noprint;
  define &aevar / "&col1text.`{super a}" style={just=l cellwidth=30%};
  define trt1 / "     0 - 2 |     (N=&pop1)|     n (%)" style={cellwidth=10%};
  define trt2 / "     3 - 6 |     (N=&pop2)|     n (%)" style={cellwidth=10%};
  define trt3 / "     7 - 11 |     (N=&pop3)|     n (%)" style={cellwidth=10%};
  define trt4 / "     12 - &up_limit |     (N=&pop4)|     n (%)" style={cellwidth=10%};
  define trt5 / "     3 - &up_limit Total |     (N=&pop5)|     n (%)" style={cellwidth=10%};
  define trt6 / "     Total`{super b} |     (N=&pop6)|     n (%)" style={cellwidth=10%};
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

%if &itprogid ne %then %do;

  %if %upcase(&itbypct)=Y %then %do;
    data final;
      set final;
	  length pct a b 8;
	  if trt6 ne '' then do;
    	a=index(trt6,'(')+1;
   	    b=index(trt6,'%');
        pct=substr(trt6,a,(b-a))*1;
	  end;
	  if trt6='' or pct>=10;
    run;
  %end;

  %mtitle2(progid=&itprogid, orient=P);

  proc report data=final headline headskip nowindows split='|' missing spacing=1;
    column page totaln order sorder &aevar ("Age Group (years) \brdrb\brdrs" trt1 trt2 trt3 trt4) trt6;
    define page /order noprint;
    define totaln / descending order noprint;
    define order /order noprint;
    define sorder /order noprint;
    define &aevar / "&col1text.`{super a}" style={just=l cellwidth=30%};
    define trt1 / "     0 - 2 |     (N=&pop1)|     n (%)" style={cellwidth=10%};
    define trt2 / "     3 - 6 |     (N=&pop2)|     n (%)" style={cellwidth=10%};
    define trt3 / "     7 - 11 |     (N=&pop3)|     n (%)" style={cellwidth=10%};
    define trt4 / "     12 - &up_limit |     (N=&pop4)|     n (%)" style={cellwidth=10%};
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

%end;

%mend rtaedecr;

%*** AEs by decreasing count;
%rtaedecr(progid=taedecr1, tcond=, itprogid=taedecr8a);
%rtaedecr(progid=taedecr2, tcond=%str(if age<17), up_limit=16, itprogid=taedecr8b);

%*** Grade >= 3 AEs by decreasing count;
%rtaedecr(progid=taedecr3, tcond=, progcond=%str(if aetoxgr>=3));
%rtaedecr(progid=taedecr4, tcond=%str(if age<17), up_limit=16, progcond=%str(if aetoxgr>=3));

%*** Serious AEs by decreasing count;
%rtaedecr(progid=taedecr5, tcond=, progcond=%str(if aeser>='Y'), itprogid=taedecr10a, itbypct=N);
%rtaedecr(progid=taedecr6, tcond=%str(if age<17), up_limit=16, progcond=%str(if aeser>='Y'), itprogid=taedecr10b,
          itbypct=N);

%*** SOC by decreasing count;
%rtaedecr(progid=taedecr7, tcond=, aevar=aebodsys, col1text=System Organ Class, row1text=Any SOC);
%rtaedecr(progid=taedecr8, tcond=%str(if age<17), up_limit=16, aevar=aebodsys, col1text=System Organ Class, row1text=Any SOC);

