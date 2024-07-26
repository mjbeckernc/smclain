data matt;
  set raw.ae;
  keep StudyID randomno aeterm aestdtc aeendtc counter;
  counter=1;
run;

proc sort data=matt;
  by studyid;

proc sort data=matt;
  by studyid randomno;

proc summary data=matt;
  class aeterm;
  var counter;
  output out=mattstats n=n1;
run;

proc sort data=matt;
  by studyid;
run;