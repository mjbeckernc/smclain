********************************************************************************;
***
*** Program:        XMB111/programs/autoexec.sas
*** Programmer:     Matt Becker
*** Date Created:   02Jun2024
***
*** Input :         none
***
*** Output:         none
***
*** Purpose:        Assign project definitions, options, libnames and macro vars
***
*** Comments:
***
*** Software:       SAS Viya 4
***
*** Modifications:
***
*** Date       Programmer        Description
*** ---------  ----------------  --------------
*** 23Jul2024  matbec            Add a comment
*** Hi Jim
*** Hi Vertex Team
*** Made a change for Joe
********************************************************************************;
cas; 
caslib _all_ assign;

proc casutil;
   droptable casdata="XMB111_AE" incaslib="public" quiet;
   droptable casdata="XMB111_DM" incaslib="public" quiet;
run;

%let pathname=/nfsshare/sashls2/mattb/XMB111;
%let rootdir=/nfsshare/sashls2/mattb/XMB111;

%let ptitle1=%str(ABCD, Inc.);
%let ptitle2=%str(XMB-111 Draft);

%let ddt=&pathname./doc/ddt.xls;
%let sdtm=&pathname./doc/sdtm.xls;

libname raw "&pathname./data/Rawdata";
libname sdtm "&pathname./data/SDTM";
*libname derived "&pathname./data/ADaM";
%sysfunc(ifc(%sysfunc(libref(derived)),libname derived "&pathname./data/ADaM",));

libname psmac   "&pathname./macros" access=read;
libname fmtdata "&pathname./data/ADaM";
libname library "&pathname./data/ADaM";

%global rawdata derdata suppkeep;
%let rawdata=raw;
%let derdata=derived;
%let suppkeep=%str(studyid rdomain usubjid idvar idvarval qnam qlabel qval qorig qeval);

%let output =&pathname./programs/Output;
%let program=&pathname./programs/;

%*** set treatment variables used in MSS, MFREQ;
%global ovtrt tottrt;
%let ovtrt=6;
%let tottrt=6;

*** set global macro vars;
%global study studynum keepdemo draft_final trtspace demovars ps ls;
%let study=;
%let studynum=;
%let keepdemo=;
%let draft_final=FINAL;
%let trtspace=4;
%let demovars=%str(usubjid age atrt rfendtc rfendtn rfstdtn rfstdtc cnstdtn q_safeas q_immuas race sex tbsa);
%let ps=50;
%let ls=130;

options linesize=136 pagesize=50 formchar="|----|+|---+=|-/\<>*";

options mautosource mrecall missing='';
options sasautos=("&pathname" "&pathname./macros" sasautos) fmtsearch=(fmtdata raw WORK);

ods path sashelp.tmplmst(read); * &derdata..matt;

%let options=mprint center ps=45 ls=132;
%let moptions=macrogen symbolgen /* mlogic */;
%let topdatef=date9.;

%let fpgfln=%str(put '\b0\f4\fs16\pard\par '; );
%let border=%str(\brdrb\brdrs);

%let ori=l;     *** landscape;

data _null_;
   daytim=put("&sysdate"d,date9.)||" "||put("&systime"t,time8.);
   call symput("nowdate", daytim);
run;

