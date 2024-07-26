proc import out=toc datafile="&pathname\programs\prod\toc.xls" dbms=xls replace;
     getnames=yes;
run;

data &derdata..toc_prog;
     length tabnum $50 title1-title6 footn1-footn8 $200 outname $60 l_source $200;
     set toc;
	 table=trim(left(table));
	 number=trim(left(number));
     tabnum=trim(left(table)) || " " || trim(left(number));
	 number=translate(number,'.','-');
     numtitle=0;
     array titles {6} title1-title6;
     do i=1 to 6;
        if titles(i)^="" then do;
           numtitle+1;
           titles(i)=trim(titles(i));
        end;
     end;
	 array footnotes {8} footn1-footn8;
	 numfoot=0;
     do i=1 to 8;
        if footnotes(i)^="" then numfoot+1;
     end;
     outname=substr(table,1,1);
	 if outname='P' then outname='L';
	 /*
	 n1=input(scan(left(number),1,'.'),??8.);
	 n2=input(scan(left(number),2,'.'),??8.);
	 n3=input(scan(left(number),3,'.'),??8.);
	 outname=trim(outname) || put(n1,z2.);
	 if n2 ne . then outname=trim(outname) || '_' || put(n2,z3.);
	 if n3 ne . then outname=trim(outname) || '_' || put(n3,z3.);
     outname=compress(outname || '_' || lowcase(progid));

	 */
     n1a=scan(left(number),1,'.');
	 if n1a ne '' and compress(n1a,'1234567890 ')='' then n1=put(input(n1a,??8.),z2.);
	 else n1=n1a;
	 n2a=scan(left(number),2,'.');
	 if n2a ne '' and compress(n2a,'1234567890 ')='' then n2=put(input(n2a,??8.),z2.);
	 else n2=n2a;
	 n3a=scan(left(number),3,'.');
	 if n3a ne '' and compress(n3a,'1234567890 ')='' then n3=put(input(n3a,??8.),z2.);
	 else n3=n3a;
	 n4a=scan(left(number),4,'.');
	 if n4a ne '' and compress(n4a,'1234567890 ')='' then n4=put(input(n4a,??8.),z2.);
	 else n4=n4a;
	 n5a=scan(left(number),5,'.');
	 if n5a ne '' and compress(n5a,'1234567890 ')='' then n5=put(input(n5a,??8.),z2.);
	 else n5=n5a;
     n6a=scan(left(number),6,'.');
	 if n6a ne '' and compress(n6a,'1234567890 ')='' then n6=put(input(n6a,??8.),z2.);
	 else n6=n6a;

	 outname=trim(outname) || n1;
	 if n2 ne '' then outname=trim(outname) || '_' || n2;
	 if n3 ne '' then outname=trim(outname) || '_' || n3;
	 if n4 ne '' then outname=trim(outname) || '_' || n4;
	 if n5 ne '' then outname=trim(outname) || '_' || n5;
	 if n6 ne '' then outname=trim(outname) || '_' || n6;

     if substr(tabnum,1,1) in('T' 'L' 'A' 'F' 'S') then outname=compress(outname || '_' || lowcase(progid));  ** added S for stat appendices - kcm 17sept09 **;
	 else outname=lowcase(progid);

     *outname=compress(outname,'-');

	 outname=lowcase(outname);

     if numtitle^=0;
     drop i table number n1 n2 n3 n4 n1a n2a n3a n4a  n5 n5a;
run;
