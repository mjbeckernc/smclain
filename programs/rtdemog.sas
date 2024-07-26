********************************************************************************;
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\rtdemog.sas
*** Programmer:     Matt Becker
*** Date Created:   02Feb2010
***
*** Input :         Derived DMs
***
*** Output:         Demographic summary table
***
*** Purpose:        To create the demographic summary table
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
  value orderf 1="Age (years)"
               2="Gender, n(%)"
			   3="Race, n(%)"
			   4="Height (cm)"
			   5="Weight (kg)"
			   6="TBSA (m`{super 2})`{super a}";
run;

%macro rtdemog(progid=tdemog1, tcond=, up_limit=17, itprogid=4a);

data dm;
  set &derdata..dm(where=(q_safeas='Y'));
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

%mss(msdata=dm, msout=age, msvar=age, msstats=n meansd median range, msprec=1, msorder=1);

%mfreq(mfdata=dm, mfout=gender, mfcntvar=sexn, mforder=2, mfdrng=%str(1,2), mffmt=sexf);

%mfreq(mfdata=dm, mfout=race, mfcntvar=x_race, mforder=3, mffmt=racef);

%mss(msdata=dm, msout=height, msvar=height, msstats=n meansd median range, msprec=0, msorder=4);

%mss(msdata=dm, msout=weight, msvar=weight, msstats=n meansd median range, msprec=0, msorder=5);

%mss(msdata=dm, msout=tbsa, msvar=tbsa, msstats=n meansd median range, msprec=1, msorder=6);

data final;
  set age gender race height weight tbsa;
  length page 4;
  page=1;
run;

proc sort data=final;
  by page order sorder;
run;

data final;
  set final;
  by page order sorder;
  length firstcol $30;
  if first.order then firstcol=put(order,orderf.);
  else firstcol='';
run;

%mtitle(progid=&progid);

proc report data=final headline headskip nowindows split='|' missing spacing=1 style(header)=[protectspecialchars=off];
  column  page order sorder firstcol text ("Age Group (years)" trt1 trt2 trt3 trt4 trt5) trt6;
  define page /order noprint;
  define order /order noprint;
  define sorder /order noprint;
  define firstcol /" " style={just=l cellwidth=12%};
  define text/ " " style={just=l cellwidth=12%};
  define trt1 / "     0 - 2 |     (N=&pop1)" style={cellwidth=11% asis=on};
  define trt2 / "     3 - 6 |     (N=&pop2)" style={cellwidth=11% asis=on};
  define trt3 / "     7 - 11 |     (N=&pop3)" style={cellwidth=11% asis=on};
  define trt4 / "     12 - &up_limit |     (N=&pop4)" style={cellwidth=11% asis=on};
  define trt5 / "     3 - &up_limit   Total |     (N=&pop5)" style={cellwidth=11% asis=on};
  define trt6 / "     Total |     (N=&pop6)" style={cellwidth=11% asis=on};
  break after page / page;
  compute before order;
    line " ";
  endcomp;
run;

ods rtf close;
ods listing;

%mpageof;

%mtitle2(progid=&itprogid, orient=P);

proc report data=final headline headskip nowindows split='|' missing spacing=1 style(header)=[protectspecialchars=off];
  column  page order sorder firstcol text ("Age Group (years)" trt1 trt2 trt3 trt4) trt6;
  define page /order noprint;
  define order /order noprint;
  define sorder /order noprint;
  define firstcol /" " style={just=l cellwidth=12%};
  define text/ " " style={just=l cellwidth=12%};
  define trt1 / "     0 - 2 |     (N=&pop1)" style={cellwidth=11% asis=on};
  define trt2 / "     3 - 6 |     (N=&pop2)" style={cellwidth=11% asis=on};
  define trt3 / "     7 - 11 |     (N=&pop3)" style={cellwidth=11% asis=on};
  define trt4 / "     12 - &up_limit |     (N=&pop4)" style={cellwidth=11% asis=on};
  define trt6 / "     Total |     (N=&pop6)" style={cellwidth=11% asis=on};
  break after page / page;
  compute before order;
    line " ";
  endcomp;
run;

ods rtf close;
ods listing;

%mpageof;

%mend rtdemog;
%rtdemog(progid=tdemog1, tcond=, itprogid=tdemog4a);
%rtdemog(progid=tdemog2, tcond=%str(if age<17), up_limit=16, itprogid=tdemog4b);
