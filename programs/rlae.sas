********************************************************************************;
*** Program:        \biometrics\499\499H01\analyses_mjb\CSR\programs\prod\rlae.sas
*** Programmer:     Matt Becker
*** Date Created:   01Apr2010
***
*** Input :         SDTM DM, STDM AE
***
*** Output:         Listing 17:  Adverse Events
***
*** Purpose:        To create the listing of adverse events
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
%macro listing(progid=tae1, subset=);

proc sort data=sdtm.ae out=ae;
  by usubjid;
  %if &subset ne %then %do;
    where &subset;
  %end;

proc sort data=sdtm.dm out=dm(keep=usubjid age);
  by usubjid;

data ae;
  merge ae(in=x) dm(in=y);
  by usubjid;
  if x;
run;

proc sort data=ae;
  by usubjid aespid;
run;

data ae;
  set ae;
  by usubjid aespid;
  length aename date_str trt_str out_str $400 aedur 8;
  page=int(_n_/4)+1;
  if aeendtc='' and aeenrf ne '' then aeendtc=propcase(aeenrf);
  aedur=(aeendy-aestdy)+1;
  if aeoccur='N' then do;
    aename='None';  
	date_str='';
	trt_str='';
	out_str='';
  end;
  else do;
    aename='V: '||trim(left(aeterm))||'`-2nP: '||trim(left(aedecod))||'`-2nS: '||trim(left(aebodsys));
    date_str='Start Date: '||trim(left(aestdtc))||'`-2n'||'Start Day: '||trim(left(aestdy))||'`-2n `-2n'||'Stop Date: '||trim(left(aeendtc))||'`-2n'||'Duration: '||trim(left(aedur));
	trt_str='Med: '||trim(left(put(aecontrt,$yesno.)))||'`-2n'||'Other: '||trim(left(put(aeaddyn,$yesno.)));
	out_str='O: '||trim(left(aeout))||'`-2n'||'A: '||trim(left(aeacn));
  end;
run;

%mcase(inds=ae, exceptl=%str('USUBJID','DATE_STR','TRT_STR'));

%mnumobs(inds=ae);

%if &nobs=0 %then %do;
  data newae;
    aename='None Reported';
  run;

  data ae;
    set ae newae;
  run;
%end;

%mtitle(progid=&progid);

footnote1;

proc report data=ae headline headskip nowindows split='|' missing spacing=2;
  column page usubjid age aespid aename date_str aesev aerel trt_str out_str 
    %if "&progid" ne "lae3" %then %do;
      aeser 
    %end;
	%if "&progid" ne "lae6" %then %do;
      aehayn
    %end;
       ;
  define page / order noprint;
  define usubjid / order 'Subject' style={just=left cellwidth=6%};
  define age / order 'Age|(Years)' format=4.1 style={just=center cellwidth=5%};
  define aespid / order noprint;
  define aename / order 'V: AE Verbatim Term|P: Preferred Term`{super a}|S: System Organ Class' flow style={just=left cellwidth=22%};
  define date_str / display 'Start/Stop Date|Duration(Days)' style={just=left cellwidth=15%};
  define aesev / display 'Severity' style={just=left cellwidth=8%};
  define aerel / display 'Relationship|to Drug`{super b}' style={just=left cellwidth=8%};
  define trt_str / display 'Con Med/|Other Trt?' style={just=left cellwidth=7%};
  define out_str / display 'Outcome (O)/|Action Taken|with Study|Treatment(A)' flow style={just=left cellwidth=15%};
  %if "&progid" ne "lae3" %then %do;
    define aeser / display 'Serious?' format=$yesno. style={just=left cellwidth=6%};
  %end;
  %if "&progid" ne "lae6" %then %do;
    define aehayn / display 'Hyper-|sensitivity`{super c}' format=$yesno. style={just=left cellwidth=7%};
  %end;
  compute after usubjid / style=[just=left];
     line 143*'_';
  endcomp;
  compute after aename;
    line "  ";
  endcomp;
  compute after page / style=[just=left];
	 line "&footn1";
	 line "&footn2";
	 line "&footn3";
	 line "&footn4";
	 line " ";
	 line "&footn11";
  endcomp;
  break after page / page;
run;

ods rtf close;
ods listing;

%mpageof;

%mend listing;
%listing(progid=lae1);
%*listing(progid=lae3, subset=%str(aeser='Y'));
%*listing(progid=lae4, subset=%str(aesev ne 'MILD' and aesev ne 'MODERATE' and aesev ne ''));
%*listing(progid=lae5, subset=%str(aerel ne '' and aerel ne 'NOT RELATED' and aerel ne 'UNLIKELY RELATED'));
%*listing(progid=lae6, subset=%str(aehayn='Y'));
