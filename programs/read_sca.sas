filename sca_rec 'C:\biometrics\XMB111\XMB111\analyses_mjb\CSR\programs\prod\simon.txt';

data myinfo;
  infile sca_rec truncover;
  input @1 scaline $256.;
  length type myinfo $100;
  keep type myinfo;
  retain prxifile prxofile prxidata prxodata;
  if _n_=1 then do;
    prxifile = prxparse("!\bJOBSPLIT: FILE INPUT (\b.*\b) \*/!");
	prxofile = prxparse("!\bJOBSPLIT: FILE OUTPUT (\b.*\b) \*/!");
	prxidata = prxparse("!\bJOBSPLIT: DATASET INPUT (\b.*\b) \*/!");
    prxodata = prxparse("!\bJOBSPLIT: DATASET OUTPUT (\b.*\b) \*/!");
  end;
  if prxmatch(prxifile,scaline)>0 then do;
    myinfo=prxposn(prxifile,1,scaline);
	type='Input File';
	output myinfo;
  end;
  else if prxmatch(prxofile,scaline)>0 then do;
    myinfo=prxposn(prxofile,1,scaline);
	type='Output File';
	output myinfo;
  end;
  else if prxmatch(prxidata,scaline)>0  and index(scaline,'WORK')<1 then do;
    myinfo=prxposn(prxidata,1,scaline);
	type='Input Dataset';
	output myinfo;
  end;
  else if prxmatch(prxodata,scaline)>0 and index(scaline,'WORK')<1 then do;
    myinfo=prxposn(prxodata,1,scaline);
	type='Output Dataset';
	output myinfo;
  end;
run;

proc sort data=myinfo noduplicates;
  by type myinfo;
run;

proc print data=myinfo;
run;

