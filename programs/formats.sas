*******************************************************************************
***
*** Program:        FORMATS.SAS
*** Programmer:     Matt Becker
*** Date Created:   02Feb2010
***
*** Purpose:        Creates formats for this study
***
*** Comments:
***
***
*** Modification History:
***
*** Date       Programmer         Description
*** ---------  ----------------   --------------
*** 
********************************************************************************;
proc format lib=&derdata;
invalue statord 'N'=1
                'MEANSD'=2
                'MEAN'=2
                'STD'=2
                'MEDIAN'=3
                'RANGE'=4
                'CI95'=5;

picture perc (round)
	0 - < 100 ='09.9'
	100='100.0' (noedit);

value sexf 1='Male'
           2='Female';

value racef 1='American Indian/Alaska Native'
            2='Asian'
            3='Black or African American'
            4='Hispanic'
			5='Native Hawaiian/Pacific Islander'
            6='White'
            7='Other';

value indicf 1="Primary Skin Graft"
             2="Skin Graft Revision"
			99="Other";

value btypef 1="Chemical"
             2="Electrical"
			 3="Flame"
			 4="Scald"
			 5="Thermal"
			 99="Other";

value gtypef 1="Mesh Graft"
             2="Sheet Graft";

value $yesno "Y"="Yes"
             "N"="No"
             "U"="Unknown";

value discreas 1="Adverse Event"
               2="Death"
			   3="Withdrawal of Consent"
			   4="Lost to Follow-up"
			   5="Study Termination by Sponsor"
			   6="Physician Decision"
			  11="Not Eligible"
			  12="Eligible, but not Treated"
			  99="Other";

value medreas 1="Lack of Appropriate Bleeding"
              2="Died Pre-treatment"
			  3="Change in Operative Plan"
			  4="Withdrew Consent"
			  5="Drug Not Available"
			 99="Other";

value exlocnf 1="Scalp"
              2="Face"
		      3="Neck"
			  4="Chest"
			  5="Back"
			  6="Abdomen/Pelvis"
			  7="Buttocks"
			  8="Extremity, upper, excluding hand"
			  9="Hand"
			 10="Extremity, lower, excluding foot"
			 11="Foot";

value sevf -99="Any"
           -55=">2"
   	         1="1"
		 	 2="2"
			 3="3";

value aesev 1="Mild"
            2="Moderate"
			3="Severe"
			4="Life Threatening"
			5="Fatal";

value bpunit 1="mL"
             2="Units";

value visitf 0="Screening/Baseline"
             1="Day 1"
			 2="Day 2"
			29="Day 29 End of Study"
			99="Log Pages"
		   901="Unscheduled Visit";

value labid 102="HGB"
            101="HCT"
			105="WBC"
			104="RBC"
			103="PLAT"
			114="LYM"
			115="MONO"
			116="NEUT"
			113="EOSO"
			112="BASO"
			401="PT"
			402="aPTT"
			403="INR"
			205="BUN"
			207="CREAT";

  value $textm 'JAN'='01'
               'FEB'='02'
			   'MAR'='03'
			   'APR'='04'
			   'MAY'='05'
			   'JUN'='06'
			   'JUL'='07'
			   'AUG'='08'
			   'SEP'='09'
			   'OCT'='10'
			   'NOV'='11'
			   'DEC'='12';
run;
