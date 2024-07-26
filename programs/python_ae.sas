%* Pulled from https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2019/3191-2019.pdf;

libname save '/nfsshare/sashls2/mattb/XMB111/data/ADaM';

proc python;
submit;

from IPython.display import display
import pandas as pd

#df = SAS.sd2df('save.ae')
df = pd.read_sas('/nfsshare/sashls2/mattb/XMB111/data/ADaM/ae.sas7bdat',format='sas7bdat')

# Like a Proc Contents
df.info()

# Printing the data frame of AE to the log (subset of lines)

print(df)

# Creating a pivot table of AE summary information using aggfunc to count 1 record per subject per AE
wkl=pd.pivot_table(df, values="USUBJID", index= ['AEBODSYS', 'AEDECOD'], columns = ['AESEV'], aggfunc=lambda x:x.nunique())

# Fill NaN (not a number) with 0
wkl = wkl.fillna(0)

#display(wkl)
#print(wkl)

# Writing the resulting dataframe to HTML so we see all records
wkl.to_html('/nfsshare/sashls2/mattb/XMB111/programs/python_ae.html')

endsubmit;
run;

PROC IML;
call ExportDataSetToR ("save.ae","ae");

submit / R;

pdf("/nfsshare/sashls2/mattb/XMB111/programs/boxplot.pdf")

barplot(table(ae$AEBODSYS)) 

dev.off()

endsubmit;
QUIT;